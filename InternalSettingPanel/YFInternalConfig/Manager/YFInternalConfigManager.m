//
//  YFInternalConfigManager.m
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import "YFInternalConfigManager.h"
#import "YFInternalConfigManager+Private.h"

#define BOOL_SUFFIX @"_bool"
#define FLOAT_SUFFIX @"_float"
#define INT_SUFFIX @"_int"
#define STRING_SUFFIX @"_string"

@implementation YFInternalConfig

+ (YFInternalConfig*)b:(BOOL)b {
    return (YFInternalConfig*)@{YFInternalConfig_Value : [NSNumber numberWithBool:b],
                                 YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeBool]};
}

+ (YFInternalConfig*)i:(int)i {
    return (YFInternalConfig*)@{YFInternalConfig_Value : [NSNumber numberWithInt:i],
                                 YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeInt]};
}

+ (YFInternalConfig*)f:(float)f {
    return (YFInternalConfig*)@{YFInternalConfig_Value : [NSNumber numberWithFloat:f],
                                YFInternalConfig_Type  : [NSNumber numberWithInteger:YFInternalConfigTypeFloat]};
}

+ (YFInternalConfig*)s:(NSString*)s {
    NSAssert(s,@"String for initiation of YFInternalConfig must not be nil");
    return (YFInternalConfig*)@{YFInternalConfig_Value : s,
                                 YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeString]};
}

+ (YFInternalConfig*)array:(NSArray *)array {
    return [YFInternalConfig array:array stringOnTableFooter:nil];
}

+ (YFInternalConfig*)array:(NSArray *)array stringOnTableFooter:(NSString *)footerString {
    for (YFInternalConfig *config in array) {
        NSAssert([YFInternalConfig getType:config] == YFInternalConfigTypeString, @"array must contain all instances of YFInternalConfig string type");
    }
    if (!array) {
        array = [NSArray array];
    }
    if (footerString) {
        return (YFInternalConfig*)@{YFInternalConfig_Value : array,
                                     YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeArray],
                       YFInternalConfig_TABLE_FOOTER_Value : footerString
                                   };
    } else {
        return (YFInternalConfig*)@{YFInternalConfig_Value : array,
                                     YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeArray]};
    }
}

+ (YFInternalConfig*)option:(NSArray *)options defaultSelectedIndex:(NSUInteger)index {
    return [YFInternalConfig option:options defaultSelectedIndex:index stringOnTableFooter:nil];
}

+ (YFInternalConfig*)option:(NSArray *)options defaultSelectedIndex:(NSUInteger)index stringOnTableFooter:(NSString *)footerString {
    for (YFInternalConfig *config in options) {
        NSAssert([YFInternalConfig getType:config] == YFInternalConfigTypeString, @"array must contain all YFInternalConfig string type");
    }
    if (!options) {
        options = [NSArray array];
    }
    NSAssert((index < [options count]), @"default selected index must not be out of bounds");
    if (footerString) {
        return (YFInternalConfig*)@{YFInternalConfig_Value : options,
                                     YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeOption],
                                     YFInternalConfig_TABLE_FOOTER_Value : footerString,
                                     YFInternalConfig_OPTION_Selected_Index: [NSNumber numberWithInteger:index]};
    } else {
        return (YFInternalConfig*)@{YFInternalConfig_Value : options,
                                     YFInternalConfig_Type : [NSNumber numberWithInteger:YFInternalConfigTypeOption],
                                     YFInternalConfig_OPTION_Selected_Index: [NSNumber numberWithInteger:index]};
    }
}

+ (id)getValue:(YFInternalConfig*)config {
    return [config objectForKey:YFInternalConfig_Value];
}

+ (NSUInteger)getSelectedIndexForOption:(YFInternalConfig*)option {
    if ([YFInternalConfig getType:option] != YFInternalConfigTypeOption) {
        [NSException raise:@"YFInternalConfigInvalidTypeException"
                    format:@"expect passed in param is not an option type, but this type: %d", [YFInternalConfig getType:option]];
    }
    return [[option objectForKey:YFInternalConfig_OPTION_Selected_Index] integerValue];
}

+ (NSString*)getFooterStringForArrayOption:(YFInternalConfig*)config {
    if ([YFInternalConfig getType:config] != YFInternalConfigTypeOption
        && [YFInternalConfig getType:config] != YFInternalConfigTypeArray) {
        [NSException raise:@"YFInternalConfigInvalidTypeException"
                    format:@"expect passed in param is not an option/array type, but this type: %d", [YFInternalConfig getType:config]];
    }
    return [config objectForKey:YFInternalConfig_TABLE_FOOTER_Value];
}

+ (YFInternalConfigType)getType:(YFInternalConfig*)config {
    return [[config objectForKey:YFInternalConfig_Type] integerValue];
}

@end

@interface YFInternalConfigManager()
@property (nonatomic, strong) NSMutableArray *configsArray;
@property (nonatomic, strong) NSMutableDictionary *configsDictionary;
@end

@implementation YFInternalConfigManager

+ (id)sharedManager {
    static YFInternalConfigManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[YFInternalConfigManager alloc] init];
    });
    
    return sharedManager;
}

- (NSString*)keyForSingleKeyDictionary:(NSDictionary*)dict {
    NSArray *keys = [dict allKeys];
    NSAssert([keys count] > 0, @"Each dictionary should have at least a key as config");
    NSString *key = [keys objectAtIndex:0];
    return key;
}

- (void)loadConfigs {
    [self.configsArray removeAllObjects];
    [self.configsDictionary removeAllObjects];

    //If you have error in this line below, most likely you have syntax error in DEFAULT_CONFIG_ARRAY in header file
    for (NSDictionary *dict in DEFAULT_CONFIG_ARRAY) {
        NSString *key = [self keyForSingleKeyDictionary:dict];
        id object = [dict objectForKey:key];
        if ([key isEqualToString:kSectionTitleKey] && object) {
            //this is a section title, just add it to config array and continue
            [self.configsArray addObject:@{key:object}];
            continue;
        }
#ifdef ENABLE_INTERNAL_SETTING
        //If ENABLE_INTERNAL_SETTING, we load value from NSUserDefault if there is one
        id storedValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (storedValue) {
            object = storedValue;
        }
#endif
        //do a existing key check
        if ([self.configsDictionary objectForKey:key]) {
            [NSException raise:@"YFInternalConfigKeyAlreadyExistsException" format:@"key %@ already exists", key];
        }
        
        //add this to array and dictionary
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:@{key:object}];
        [self.configsArray addObject:resultDict];
        [self.configsDictionary addEntriesFromDictionary:resultDict];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _configsArray = [[NSMutableArray alloc] init];
        _configsDictionary = [[NSMutableDictionary alloc] init];
        //Load default values and values stored if it is ENABLE_INTERNAL_SETTING version
        [self loadConfigs];
    }
    return self;
}

//accessor
- (void)checkKey:(NSString*)key {
    if (!key) {
        [NSException raise:@"YFInternalConfigInvalidKey" format:@"key cannot be nil"];
    }
}

- (BOOL)boolForKey:(NSString*)key {
    [self checkKey:key];
    return [[[self.configsDictionary objectForKey:key] objectForKey:YFInternalConfig_Value] boolValue];
}

- (float)floatForKey:(NSString*)key {
    [self checkKey:key];
    return [[[self.configsDictionary objectForKey:key] objectForKey:YFInternalConfig_Value] floatValue];
}

- (int)intForKey:(NSString*)key {
    [self checkKey:key];
    return [[[self.configsDictionary objectForKey:key] objectForKey:YFInternalConfig_Value] intValue];
}

- (NSString*)stringForKey:(NSString*)key {
    [self checkKey:key];
    NSString *string = [[self.configsDictionary objectForKey:key] objectForKey:YFInternalConfig_Value];
    NSAssert([string isKindOfClass:[NSString class]], @"key should contain NSString instance!");
    return string;
}

- (NSArray*)configArray {
    return self.configsArray;
}

- (NSArray*)rawArrayForKey:(NSString*)key {
    [self checkKey:key];
    NSArray *array = [[self.configsDictionary objectForKey:key] objectForKey:YFInternalConfig_Value];
    NSAssert([array isKindOfClass:[NSArray class]], @"key should contain NSArray instance!");
    return array;
}

- (NSArray*)arrayForKey:(NSString *)key {
    NSArray *array = [self rawArrayForKey:key];
    NSMutableArray *stringArray = [NSMutableArray array];
    for (YFInternalConfig *config in array) {
        NSString *string = [YFInternalConfig getValue:config];
        if (string && [string isKindOfClass:[NSString class]]) {
            [stringArray addObject:string];
        } else {
            [NSException raise:@"YFInternalConfigInconsistentTypeException" format:@"YFInternalConfig Array type must contain string instances wrapped by YFInternalConfig"];
        }
    }
    return stringArray;
}

- (NSArray*)optionsForKey:(NSString *)key {
    return [self arrayForKey:key];
}

- (NSString*)optionForKey:(NSString *)key {
    [self checkKey:key];
    NSArray *options = [self rawArrayForKey:key];
    NSAssert([options isKindOfClass:[NSArray class]], @"key should contain NSArray instance!");
    NSUInteger index = [[[self.configsDictionary objectForKey:key] objectForKey:YFInternalConfig_OPTION_Selected_Index] integerValue];
    return [[options objectAtIndex:index] objectForKey:YFInternalConfig_Value];
}

//setter
- (NSError*)storeObject:(id)object forKey:(NSString*)key
{
    NSAssert(object, @"object to be stored should be non-nil");
    NSMutableDictionary *targetDict = nil;
    for (NSMutableDictionary *singleKeyDict in self.configsArray) {
        if ([[self keyForSingleKeyDictionary:singleKeyDict] isEqualToString:key]) {
            targetDict = singleKeyDict;
            break;
        }
    }
    if (![self.configsDictionary objectForKey:key] || !targetDict) {
        return [NSError errorWithDomain:@"YFInternalConfigManagerConfigKeyNotFound" code:-1 userInfo:@{@"key" : key}];
    }
    [self.configsDictionary setObject:object forKey:key];
    [targetDict setObject:object forKey:key];

    //Store in NSUserDefault
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return nil;
}

- (NSError*)storeBool:(BOOL)b forKey:(NSString*)key {
    [self checkKey:key];
    return [self storeObject:[YFInternalConfig b:b] forKey:key];
}

- (NSError*)storeInt:(int)i forKey:(NSString*)key {
    [self checkKey:key];
    return [self storeObject:[YFInternalConfig i:i] forKey:key];
}

- (NSError*)storeFloat:(float)f forKey:(NSString*)key {
    [self checkKey:key];
    return [self storeObject:[YFInternalConfig f:f] forKey:key];
}

- (NSError*)storeString:(NSString*)s forKey:(NSString*)key {
    [self checkKey:key];
    return [self storeObject:[YFInternalConfig s:s] forKey:key];
}

- (NSError*)storeArray:(NSArray*)array forKey:(NSString*)key {
    [self checkKey:key];
    return [self storeObject:[YFInternalConfig array:array] forKey:key];
}

- (NSError*)storeOptions:(NSArray*)options selectedIndex:(NSUInteger)index forKey:(NSString*)key {
    [self checkKey:key];
    return [self storeObject:[YFInternalConfig option:options defaultSelectedIndex:index] forKey:key];
}

@end

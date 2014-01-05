//
//  YFInternalConfigManager+Private.h
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import "YFInternalConfigManager.h"

#define YFInternalConfig_Value @"value"
#define YFInternalConfig_Type @"key"
#define YFInternalConfig_OPTION_Selected_Index @"option_selected_index"
#define YFInternalConfig_TABLE_FOOTER_Value @"table_footer_key"

//CAUTION: change the assigned int value here will corrupt stored config!
typedef NS_ENUM(NSInteger, YFInternalConfigType) {
	YFInternalConfigTypeBool = 1,
	YFInternalConfigTypeInt = 2,
    YFInternalConfigTypeFloat = 3,
    YFInternalConfigTypeString = 4,
    YFInternalConfigTypeArray = 5,
    YFInternalConfigTypeOption = 6
};

@interface YFInternalConfig (Private)
+ (id)getValue:(YFInternalConfig*)config;
+ (YFInternalConfigType)getType:(YFInternalConfig*)config;
+ (NSUInteger)getSelectedIndexForOption:(YFInternalConfig*)option;
+ (NSString*)getFooterStringForArrayOption:(YFInternalConfig*)config;
@end

@interface YFInternalConfigManager (Private)
- (NSArray*)configArray;
//just a helper
- (NSString*)keyForSingleKeyDictionary:(NSDictionary*)dict;
//setter, in private because we only want the setting panel view controller to set and store the config values
- (NSError*)storeBool:(BOOL)boolean forKey:(NSString*)key;
- (NSError*)storeInt:(int)integer forKey:(NSString*)key;
- (NSError*)storeFloat:(float)floatValue forKey:(NSString*)key;
- (NSError*)storeString:(NSString*)string forKey:(NSString*)key;
//use these to get the array or options then manipulate the configs inside
- (NSArray*)arrayForKey:(NSString *)key;
- (NSArray*)optionsForKey:(NSString *)key;
- (NSString*)optionForKey:(NSString *)key;
@end

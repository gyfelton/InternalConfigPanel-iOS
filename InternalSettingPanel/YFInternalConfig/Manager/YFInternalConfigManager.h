//
//  YFInternalConfigManager.h
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YFInternalConfig : NSDictionary
//use these constructors to initiate a config
+ (YFInternalConfig*)b:(BOOL)b;
+ (YFInternalConfig*)i:(int)i;
+ (YFInternalConfig*)f:(float)f;
+ (YFInternalConfig*)s:(NSString*)s;
//the array here must consist of all YFInternalConfig instances, otherwise exception will be thrown
+ (YFInternalConfig*)array:(NSArray*)array;
+ (YFInternalConfig*)array:(NSArray*)array stringOnTableFooter:(NSString*)footerString;
+ (YFInternalConfig*)option:(NSArray*)options defaultSelectedIndex:(NSUInteger)index;
+ (YFInternalConfig*)option:(NSArray*)options defaultSelectedIndex:(NSUInteger)index stringOnTableFooter:(NSString*)footerString;
@end

/////////////////////////////////////////////////////////////////
///////////////User Guide to internal setting panel//////////////
//Step 1:
//Add config key below, type is in its suffix,
//and its corresponding value (string) will be displayed on the actual internal setting panel

//IMPORTANT
//Naming convention: add one of the following to suffix to indicate the type
// _bool: key's object is a BOOL value
// _int: key's object is a int value
// _float: key's object is a float value
// _string: key's object is a string value
// _array: key's object is an array which can be added/deleted from config panel, only support NSString type
// _option: key's object is an array but getter will return only the selected single option, , only support NSString type
// example: #define kEnableNuke_bool @"Enable Nuke"

/*Other examples:
 #define kTest1_bool @"Test Boolean"
 #define kTest2_int @"Test Int"
 #define kTest3_float @"Test Float"
 #define kTest4_string @"Test String"
 #define kTest5_array @"Test List"
 #define kTest6_option @"Test Options"
*/
#define kTextfieldPlaceholder_bool @"Enable placeholder on textfields"
#define kTest2_int @"Test Int"
#define kTest3_float @"Test Float"
#define kSendEmailFrom_option @"Email Sender"
#define kSendEmailList_array @"Default email recipients"

//Step 2:
//Indicate its location to be displayed on the acutal internal setting panel
//And the default values will be used for PRODUCTION if not get rid of!
//To do so, just insert into the array below at a appropriate position as key-value pair.
//Note: its default value, the type of the value and the suffix of the string will NOT be checked
//so be careful what you give to the key (use naming convention to check)
//insert the following key-value pair to be a section title: {kSectionTitle: @"Section Title"},
//you can leave @"" as empty section header to create a section

//////////////Do not change this!///////////
#define kSectionTitleKey @"YFInternalConfigManagerSectionTitleKey"
////////////////////////////////////////////

//comment the following to make sure internal setting configs is applied to certain target (by having this set as macro in testing target)

#ifndef ENABLE_INTERNAL_SETTING
#define ENABLE_INTERNAL_SETTING
#endif

//Note that he first entry must be a sectionTitle (can be with @""), or exception will throw
/*examples:
 @{kSectionTitleKey : @"Just for test"},\
 @{kTest1_bool : [YFInternalConfig b:YES]},\
 @{kTest2_int : [YFInternalConfig i:1]},\
 @{kTest3_float : [YFInternalConfig f:0.5]},\
 @{kTest4_string : [YFInternalConfig s:@"www.test.com"]},\
 //Note: array must contain YFInternalConfig instances and must be having same types!
 @{kTest5_array : [YFInternalConfig array:@[[YFInternalConfig s:@"test1"], [YFInternalConfig s:@"test2"], [YFInternalConfig s:@"test3"]]]},\
 @{kTest5_array : [YFInternalConfig array:@[[YFInternalConfig s:@"1"], [YFInternalConfig s:@"2"], [YFInternalConfig s:@"3"]] defaultSelectionIndex:0]},\
 */
#define DEFAULT_CONFIG_ARRAY \
@[\
  @{kSectionTitleKey : @"Email Sending Settings"},\
  @{kTextfieldPlaceholder_bool: [YFInternalConfig b:YES]},\
  @{kTest2_int: [YFInternalConfig i:0]}, \
  @{kTest3_float: [YFInternalConfig f:5.0f]}, \
  @{kSectionTitleKey : @""},\
  @{kSendEmailFrom_option: [YFInternalConfig option:@[[YFInternalConfig s:@"test1@test.com"], [YFInternalConfig s:@"test@test.com"]] defaultSelectedIndex:0 stringOnTableFooter:@"You must restart the app to apply this change!"] },\
  @{kSendEmailList_array : [YFInternalConfig array:@[[YFInternalConfig s:@"test2@test.com"],[YFInternalConfig s:@"test3@test.com"],[YFInternalConfig s:@"test4@test.com"]]]},\
 ]\

//Step 3: You are almost done! Now use one of the following method to get the value you want
//Note that you cannot change any of the config programatically/inside the code, it can only be done on panel
//Change the default value instead if you do want to change the config
/////////////////////////////////////////////////////////////////


@interface YFInternalConfigManager : NSObject

+ (YFInternalConfigManager*)sharedManager;

//accessors
- (BOOL)boolForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;

//only return NSString type in the array
- (NSArray*)arrayForKey:(NSString*)key;

//Only return the selected option among the list
- (NSString*)optionForKey:(NSString*)key;
- (NSError*)storeArray:(NSArray*)array forKey:(NSString*)key;
- (NSError*)storeOptions:(NSArray*)options selectedIndex:(NSUInteger)index forKey:(NSString*)key;
@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Combobox.h"

// https://github.com/facebook/react-native/issues/17703
#import <React/RCTUIManager.h>

@interface PickerWithAppearanceEvent : UIPickerView
  @property UIView* overlay;
  @property UIView* combobox;
  @property BOOL wasDismissed;
@end

@implementation PickerWithAppearanceEvent

- (void)didMoveToSuperview {
  NSLog(@"didMoveToSuperview");

  if (self.wasDismissed) {
    // This event gets called once after the picker is dismissed, so we're
    // ignoring the first time it gets called after being dismissed.
    // WTF, Steve.
    self.wasDismissed = false;
  } else {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (self.overlay != NULL) {
        [self.overlay removeFromSuperview];
        self.overlay = NULL;
    }

    UIView* alphaView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    alphaView.opaque = NO;
    alphaView.backgroundColor = [UIColor colorWithRed:0.190196078431373 green:0.192156862745098 blue:0.190196078431373 alpha:0.5];
    self.overlay = alphaView;

    [window insertSubview:self.overlay atIndex:window.subviews.count];
    NSLog(@"didMoveToSuperview added overlay");

    UITapGestureRecognizer *singleFingerTap = 
      [[UITapGestureRecognizer alloc] initWithTarget:self 
                                              action:@selector(onOverlayClicked:)];
    [self.overlay addGestureRecognizer:singleFingerTap];
  }
}

- (void)onOverlayClicked:(UITapGestureRecognizer *)recognizer {
  [self.combobox resignFirstResponder];

  if (self.overlay != NULL) {
      [self.overlay removeFromSuperview];
      self.overlay = NULL;
  }

  self.wasDismissed = true;
}

@end

@interface ComboboxView : UITextView<UIPickerViewDataSource, UIPickerViewDelegate>
  @property NSArray* items;
  @property NSString* placeholder;
  @property NSObject* selectedItem;
  @property NSString* itemAvailableImageName;
  @property NSString* itemNotAvailableImageName;
  @property (nonatomic, copy) RCTBubblingEventBlock onSelectedItemChanged;

  // TODO: Remove this from the public interface, it is an implementation detail.
  @property PickerWithAppearanceEvent* picker;
@end

@implementation ComboboxView

// Returns the number of columns that the picker has. This is normally `1`,
// unless the picker allows for selecting several values at once (such as a
// typical date picker, which lets the user pick a year, a month, and a day).
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

// Returns the number of rows that the picker has.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return self.items.count + 1;
}

- (UIView*)renderRowViewForStringItem:(NSString*)rowObject {
  NSString* rowText = rowObject;
    
  UILabel* label = [[UILabel alloc] init];
  [label setText:rowText];
  [label sizeToFit];

  UIStackView* result = [[UIStackView alloc] init];
  result.distribution = UIStackViewDistributionFill;
  NSInteger verticalPadding = 5;
  NSInteger horizontalPadding = 10;
  result.layoutMargins = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
  [result setLayoutMarginsRelativeArrangement:YES];
  [result addArrangedSubview:label];

  return result;
}

- (UIView*)renderRowViewForDictionaryItem:(NSDictionary*)rowObject {

  NSString* rowText = [rowObject valueForKey:@"text"];
  NSNumber* isAvailable = [rowObject valueForKey:@"isAvailable"];

  NSString* imageName = [[NSNumber numberWithInt:1] isEqualToNumber:isAvailable] ? self.itemAvailableImageName : self.itemNotAvailableImageName;

  UIImage* _Nonnull image = [UIImage imageNamed:imageName];
  UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    
  [imageView.widthAnchor constraintEqualToConstant:40].active = true;
    
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = CGRectMake(0, 0, 40, 40);
  
  UILabel* label = [[UILabel alloc] init];
  [label setText:rowText];
  [label sizeToFit];

  UIStackView* result = [[UIStackView alloc] init];
  result.distribution = UIStackViewDistributionFill;
  NSInteger verticalPadding = 5;
  NSInteger horizontalPadding = 10;
  result.layoutMargins = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
  [result setLayoutMarginsRelativeArrangement:YES];
  [result addArrangedSubview:imageView];
  [result addArrangedSubview:label];
    
  return result;
}

// Returns the value of the specified row and column of the picker data.
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
  NSLog(@"pickerView viewForRow %ld", (long)row);

  if (row == 0) {
    return [self renderRowViewForStringItem:self.placeholder];
  }

  // For some reason, iOS now sometimes asks for a nonzero row when there is an empty list of items.
  if (row > self.items.count) {
    return [self renderRowViewForStringItem:self.placeholder];
  }
    
  NSObject* rowObject = self.items[row - 1];
  NSLog(@"rowObject %@", rowObject);

  if ([rowObject isKindOfClass:[NSDictionary class]]) {
    return [self renderRowViewForDictionaryItem:(NSDictionary *)rowObject];
  } else if ([rowObject isKindOfClass:[NSString class]]) {
    return [self renderRowViewForStringItem:(NSString *)rowObject];
  } else {
    [NSException raise:@"UnsupportedRowObjectType" format:@"Row object must be an NSString or NSDictionary pointer."];
  }

  return NULL;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  NSLog(@"pickerView didSelectRow %ld", (long)row);

  NSDictionary* eventData;
  if (row > 0) {
    NSObject* rowObject = self.items[row - 1];
    
    NSDictionary* selectedItem;
    if ([rowObject isKindOfClass:[NSDictionary class]]) {
      selectedItem = (NSDictionary *)rowObject;
    } else if ([rowObject isKindOfClass:[NSString class]]) {
      selectedItem = @{
        @"text": rowObject,
        @"isAvailable": @(true),
      };
    } else {
      [NSException raise:@"UnsupportedRowObjectType" format:@"Row object must be an NSString or NSDictionary pointer."];
    }

    eventData = @{
      @"selectedItem": selectedItem,
    };
  } else {
    eventData = @{};
  }

  if (self.onSelectedItemChanged != NULL) {
    self.onSelectedItemChanged(eventData);
  }
}

- (NSInteger)findIndex:(NSArray*)listToSearch objectToFind:(NSString*)objectToFind {
    NSLog(@"findIndex looking for %@", objectToFind);

    if (listToSearch == NULL || objectToFind == NULL) {
        return 0;
    }

    for (int i = 0; i < listToSearch.count; i++) {

        NSObject* currentObject = listToSearch[i];
        NSString* currentObjectText = [self getItemText:currentObject];
        NSLog(@"findIndex looking at %@", currentObjectText);

        if ([currentObjectText isEqualToString:objectToFind]) {
            return i;
        }
    }

    return 0;
}

- (NSInteger)findSelectedItemPositionInData {

  return [self findIndex:self.items objectToFind:[self getItemText:self.selectedItem]];
}

- (void)showSelection {
    if (self.selectedItem == NULL || self.items == NULL) {
        //NSLog(@"no rows to select");
        self.text = self.placeholder;
    } else {
        //NSInteger selectedRow = [self findSelectedItemPositionInData] + 1;
        //NSLog(@"selecting row %ld", (long)selectedRow);
        //[self.picker selectRow:selectedRow inComponent:0 animated:YES];
        self.text = [self getItemText:self.selectedItem];
    }
}

- (NSString *)getItemText:(NSObject *)item {
    if ([item isKindOfClass:[NSDictionary class]]) {
        return [item valueForKey:@"text"];
    } else if ([item isKindOfClass:[NSString class]]) {
        return (NSString *)item;
    } else {
        NSString* error = @"Current object must be an NSString or NSDictionary pointer.";
        [NSException raise:@"UnsupportedRowObjectType" format:@"%@", error];
        return error;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 40.0;
}

-(void)layoutSubviews{
  [self recenter];
}

-(void)recenter{
  // using self.contentSize doesn't work correctly, have to calculate content size
  CGSize contentSize = [self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
  CGFloat topCorrection = (self.bounds.size.height - contentSize.height * self.zoomScale) / 2.0;
  self.contentOffset = CGPointMake(0, -topCorrection);
}

- (void)onDoneButtonClicked {
  NSLog(@"Done button clicked!");
  [self resignFirstResponder];
  if (self.picker.overlay != NULL) {
    [self.picker.overlay removeFromSuperview];
    self.picker.overlay = NULL;
  }
  self.picker.wasDismissed = true;
}

@end

@implementation ComboboxManager

RCT_EXPORT_MODULE(Combobox)

/**
 * From:
 *   - https://reactnative.dev/docs/native-components-ios#properties
 *   - https://github.com/facebook/react-native/issues/1386
 *
 * These macros can be used when you need to provide custom logic for setting
 * view properties. The macro should be followed by a method body, which can
 * refer to "json", "view" and "defaultView" to implement the required logic.
 *
 * #define RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass) \
 * + (NSString *)getPropConfigView_##name { return @#type; } \
 * - (void)set_##name:(id)json forView:(viewClass *)view withDefaultView:(viewClass *)defaultView
 *
 * Implicit parameters that are available as local variables in the function body:
 *   - 'json': The raw property value passed in from Javascript code.
 *   - 'view': The root UI element instance.
 *   - 'defaultView': Used to reset the property back to the default value if the Javascript code sends us a null sentinel (what does this mean, how do we do it, when, and why?).
 */
RCT_CUSTOM_VIEW_PROPERTY(
  /* property name */ placeholder,
  /* 'json' property value parameter type */ NSString,
  /* class of the root UI element */ ComboboxView)
{
  view.placeholder = json;
  
  [view showSelection];
}

/**
 * From:
 *   - https://reactnative.dev/docs/native-components-ios#properties
 *   - https://github.com/facebook/react-native/issues/1386
 *
 * These macros can be used when you need to provide custom logic for setting
 * view properties. The macro should be followed by a method body, which can
 * refer to "json", "view" and "defaultView" to implement the required logic.
 *
 * #define RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass) \
 * + (NSString *)getPropConfigView_##name { return @#type; } \
 * - (void)set_##name:(id)json forView:(viewClass *)view withDefaultView:(viewClass *)defaultView
 *
 * Implicit parameters that are available as local variables in the function body:
 *   - 'json': The raw property value passed in from Javascript code.
 *   - 'view': The root UI element instance.
 *   - 'defaultView': Used to reset the property back to the default value if the Javascript code sends us a null sentinel (what does this mean, how do we do it, when, and why?).
 */
RCT_CUSTOM_VIEW_PROPERTY(
  /* property name */ selectedItem,
  /* 'json' property value parameter type */ NSObject,
  /* class of the root UI element */ ComboboxView)
{
    NSLog(@"selectedItem property set to: %@", json);
    view.selectedItem = json;

    if (view.selectedItem == NULL) {
        // By default, the iOS picker keeps the same row selected, even if you switch
        // the list of items or set the selection to `null`. This overrides that
        // behavior, so that the row selection doesn't incorrectly persist across
        // different data sources or after a selection reset.
        [view.picker selectRow:0 inComponent:0 animated:YES];
    }

    [view showSelection];
}

/**
 * From:
 *   - https://reactnative.dev/docs/native-components-ios#properties
 *   - https://github.com/facebook/react-native/issues/1386
 *
 * These macros can be used when you need to provide custom logic for setting
 * view properties. The macro should be followed by a method body, which can
 * refer to "json", "view" and "defaultView" to implement the required logic.
 *
 * #define RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass) \
 * + (NSString *)getPropConfigView_##name { return @#type; } \
 * - (void)set_##name:(id)json forView:(viewClass *)view withDefaultView:(viewClass *)defaultView
 *
 * Implicit parameters that are available as local variables in the function body:
 *   - 'json': The raw property value passed in from Javascript code.
 *   - 'view': The root UI element instance.
 *   - 'defaultView': Used to reset the property back to the default value if the Javascript code sends us a null sentinel (what does this mean, how do we do it, when, and why?).
 */
RCT_CUSTOM_VIEW_PROPERTY(
  /* property name */ items,
  /* 'json' property value parameter type */ NSArray,
  /* class of the root UI element */ ComboboxView)
{
  NSLog(@"items RCT_CUSTOM_VIEW_PROPERTY called: %@", json);
  view.items = json;
  [view showSelection];
}

/**
 * From:
 *   - https://reactnative.dev/docs/native-components-ios#properties
 *   - https://github.com/facebook/react-native/issues/1386
 *
 * These macros can be used when you need to provide custom logic for setting
 * view properties. The macro should be followed by a method body, which can
 * refer to "json", "view" and "defaultView" to implement the required logic.
 *
 * #define RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass) \
 * + (NSString *)getPropConfigView_##name { return @#type; } \
 * - (void)set_##name:(id)json forView:(viewClass *)view withDefaultView:(viewClass *)defaultView
 *
 * Implicit parameters that are available as local variables in the function body:
 *   - 'json': The raw property value passed in from Javascript code.
 *   - 'view': The root UI element instance.
 *   - 'defaultView': Used to reset the property back to the default value if the Javascript code sends us a null sentinel (what does this mean, how do we do it, when, and why?).
 */
RCT_CUSTOM_VIEW_PROPERTY(
  /* property name */ itemAvailableImageName,
  /* 'json' property value parameter type */ String,
  /* class of the root UI element */ ComboboxView)
{
  view.itemAvailableImageName = json;

  [view showSelection];
}

/**
 * From:
 *   - https://reactnative.dev/docs/native-components-ios#properties
 *   - https://github.com/facebook/react-native/issues/1386
 *
 * These macros can be used when you need to provide custom logic for setting
 * view properties. The macro should be followed by a method body, which can
 * refer to "json", "view" and "defaultView" to implement the required logic.
 *
 * #define RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass) \
 * + (NSString *)getPropConfigView_##name { return @#type; } \
 * - (void)set_##name:(id)json forView:(viewClass *)view withDefaultView:(viewClass *)defaultView
 *
 * Implicit parameters that are available as local variables in the function body:
 *   - 'json': The raw property value passed in from Javascript code.
 *   - 'view': The root UI element instance.
 *   - 'defaultView': Used to reset the property back to the default value if the Javascript code sends us a null sentinel (what does this mean, how do we do it, when, and why?).
 */
RCT_CUSTOM_VIEW_PROPERTY(
  /* property name */ itemNotAvailableImageName,
  /* 'json' property value parameter type */ String,
  /* class of the root UI element */ ComboboxView)
{
  view.itemNotAvailableImageName = json;

  [view showSelection];
}

RCT_EXPORT_VIEW_PROPERTY(onSelectedItemChanged, RCTBubblingEventBlock)

RCT_EXPORT_METHOD(reloadItems:(nonnull NSNumber *)reactTag items:(NSArray*)items)
{ 
  //RCTLog(@"reloadItems called: %@, %@", reactTag, items);
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    UIView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[ComboboxView class]]) {
      RCTLog(@"expecting ComboboxView, got: %@", view);
      return;
    }
    
    ComboboxView *combobox = (ComboboxView *)view;
    combobox.items = items;
    [combobox.picker reloadAllComponents];
  }];
}

- (UIView *)view
{
  ComboboxView* view = [[ComboboxView alloc] init];
  view.editable = NO;

  PickerWithAppearanceEvent* combobox = [[PickerWithAppearanceEvent alloc] init];
  combobox.dataSource = view;
  combobox.delegate = view;

  CGFloat width = [[UIScreen mainScreen] bounds].size.width;
  UIView* toolBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f, width, 44.0f)];
  toolBar.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.0f];

  UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
  [doneBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
  [doneBtn addTarget:view action:@selector(onDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
  [doneBtn setFrame:CGRectMake(width-70, 6, 50, 32)];
  [toolBar addSubview:doneBtn];

  [toolBar sizeToFit];

  view.picker = combobox;
  view.picker.combobox = view;

  view.inputView = combobox;
  view.inputAccessoryView = toolBar;

  return view;
}

@end

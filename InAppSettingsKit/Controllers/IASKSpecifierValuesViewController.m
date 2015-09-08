//
//  IASKSpecifierValuesViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKSpecifierValuesViewController.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKMultipleValueSelection.h"
#import "IASKAppSettingsViewController.h"

#define kCellValue      @"kCellValue"

@interface IASKSpecifierValuesViewController()

@property (nonatomic, strong, readonly) IASKMultipleValueSelection *selection;

@end

@implementation IASKSpecifierValuesViewController

@synthesize tableView=_tableView;
@synthesize currentSpecifier=_currentSpecifier;
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;

- (void)setSettingsStore:(id <IASKSettingsStore>)settingsStore {
    _settingsStore = settingsStore;
    _selection.settingsStore = settingsStore;
}

- (void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.view = _tableView;

    _selection = [IASKMultipleValueSelection new];
    _selection.tableView = _tableView;
    _selection.settingsStore = _settingsStore;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_currentSpecifier) {
        [self setTitle:[_currentSpecifier title]];
        _selection.specifier = _currentSpecifier;
    }
    
    if (_tableView) {
        [_tableView reloadData];

		// Make sure the currently checked item is visible
        [_tableView scrollToRowAtIndexPath:_selection.checkedItem
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
  [self bl_setStyles];
	[super viewWillAppear:animated];
}

- (IASKAppSettingsViewController *)bl_getMainSettingsVc {
  UINavigationController *navVc = (UINavigationController *) self.parentViewController;
  return navVc.viewControllers.firstObject;
}

- (void)bl_setStyles {
  self.view.backgroundColor = [self bl_getMainSettingsVc].view.backgroundColor;
  self.tableView.separatorColor = [self bl_getMainSettingsVc].tableView.separatorColor;
  [self.tableView setTintColor:[self bl_getMainSettingsVc].navigationItem.rightBarButtonItem.tintColor];
}

- (void)viewDidAppear:(BOOL)animated {
	[_tableView flashScrollIndicators];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    _selection.tableView = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentSpecifier multipleValuesCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_currentSpecifier footerText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:kCellValue];
    NSArray *titles         = [_currentSpecifier multipleTitles];
    NSArray *images         = [_currentSpecifier multipleImages];
	
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue];
    }

    [_selection updateSelectionInCell:cell indexPath:indexPath];
    [self bl_setCellStyles:cell];
    @try {
		[[cell textLabel] setText:[self.settingsReader titleForStringId:titles[indexPath.row]]];
    cell.imageView.image = nil;
    if (images && images[(NSUInteger) indexPath.row]) {
      cell.imageView.image = [UIImage imageNamed:images[(NSUInteger) indexPath.row]];
    }
	}
	@catch (NSException * e) {}
    return cell;
}

- (void)bl_setCellStyles:(UITableViewCell *)cell {
  IASKAppSettingsViewController *vc = [self bl_getMainSettingsVc];
  UITableViewCell *styleCell = [vc tableView:vc.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                   inSection:0]];
  cell.textLabel.textColor = styleCell.textLabel.textColor;
  cell.textLabel.font = styleCell.textLabel.font;
  cell.backgroundColor = styleCell.backgroundColor;
  cell.detailTextLabel.textColor = styleCell.detailTextLabel.textColor;
  cell.detailTextLabel.font = styleCell.detailTextLabel.font;
  cell.selectedBackgroundView = [UIView new];
  cell.selectedBackgroundView.backgroundColor = styleCell.selectedBackgroundView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_selection selectRowAtIndexPath:indexPath];
}

- (CGSize)contentSizeForViewInPopover {
    return [[self view] sizeThatFits:CGSizeMake(320, 2000)];
}

@end

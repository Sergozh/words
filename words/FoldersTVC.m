//
//  FoldersTVC.m
//  Words
//
//  Created by Егор on 28/03/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "FoldersTVC.h"
#import "NotebooksTVC.h"
#import "Folder.h"
#import "Cell.h"

@interface FoldersTVC () <UITextFieldDelegate>
@property NSArray *folders;
@property UITextField *nameField;

@property UIBarButtonItem *plusButton;
@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *cancelButton;

@property BOOL editingName;
@property NSInteger editingCellIndex;
@property Folder *folder;
@property BOOL editingControlsAreForNewRow;

@end

@implementation FoldersTVC

-(void)awakeFromNib{
  [super awakeFromNib];
  NSData *foldersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"folders"];
  if (foldersData){
    _folders = [NSKeyedUnarchiver unarchiveObjectWithData:foldersData];
  }
  
  _nameField = [[UITextField alloc] init];
  _nameField.placeholder = NSLocalizedString(@"newFolderName", nil);
  _nameField.borderStyle = UITextBorderStyleNone;
  _nameField.backgroundColor = [UIColor whiteColor];
  _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
  _nameField.delegate = self;
  [_nameField addTarget:self action:@selector(nameFieldChanged) forControlEvents:UIControlEventEditingChanged];
  
  _plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                              target:self action:@selector(add)];
  self.navigationItem.rightBarButtonItem = _plusButton;
  
  _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                              target:self action:nil];
  
  _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                target:self action:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAndReloadData:) name:@"saveFolders" object:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  if (self.doneButton.enabled){
    if (self.editingControlsAreForNewRow){
      [self doneAdding];
    }
    else{
      [self doneRenaming];
    }
  }
  return YES;
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  NSArray *notebooks;
  NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"migratedToFolders"];
  if (!num){
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"launchedBefore"];
    NSData *notebooksData = [[NSUserDefaults standardUserDefaults] dataForKey:@"notebooks"];
    if (notebooksData){
      notebooks = [NSKeyedUnarchiver unarchiveObjectWithData:notebooksData];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"migratedToFolders"];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reorder) name:@"reorderPlease" object:nil];
  
  self.navigationItem.title = NSLocalizedString(@"foldersTitle", nil);
  
  if (animated){
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastFolder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return;
  }
  
  BOOL launchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchedBefore"];
  if (!launchedBefore){
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"launchedBefore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    Notebook *notebook = [[Notebook alloc] init];
    NSString *lang = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    NSString *folderName;
    NSString *notebookName;
    
    NSLog(@"First time. Lang is %@", lang);
    if ([lang isEqualToString:@"en"]){
      folderName = @"First Folder";
      notebookName = @"Words";
    }
    if ([lang isEqualToString:@"ru"]){
      folderName = @"Первая папка";
      notebookName = @"Слова";
    }
    notebook.name = notebookName;
    
    Folder *folder = [[Folder alloc] init];
    if (notebooks){
      folder.notebooks = notebooks;
    }
    else{
      folder.notebooks = @[notebook];
    }
    folder.name = folderName;
    [self addFolder:folder atIndex:0];
    
    [self saveAndReloadData:NO];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastNotebook"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastFolder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NotebooksTVC *notebooks = [self.storyboard instantiateViewControllerWithIdentifier:@"notebooksTVC"];
    notebooks.folder = folder;
    notebooks.navigationItem.title = folderName;
    NSLog(@"Folders tvc pushing new notebooks tvc in view will appear because the app was not launched before");
    [self.navigationController pushViewController:notebooks animated:NO];
    return;
  }
  
  num = nil;
  num = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastFolder"];
  if (num){
    if (_folders.count > [num integerValue]){
      
      Folder *folder = _folders[[num integerValue]];
      NotebooksTVC *notebooks = [self.storyboard instantiateViewControllerWithIdentifier:@"notebooksTVC"];
      
      notebooks.folder = folder;
      notebooks.navigationItem.title = folder.name;
      [self.navigationController pushViewController:notebooks animated:NO];
      NSLog(@"Folders tvc pushing new notebooks tvc in view will appear because there is a lastFolder key in defaults");
    }
  }
}

-(void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  NSLog(@"Disappearing");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reorderPlease" object:nil];
}

-(void)nameFieldChanged{
  _doneButton.enabled = _nameField.text.length > 0;
}


#pragma mark - Table view data source

-(void)reorder{
  self.tableView.delaysContentTouches = NO;
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneReordering)];
  self.navigationItem.rightBarButtonItems = @[done];
  [self.tableView setEditing:YES animated:YES];
}

-(void)doneReordering{
  [self.tableView setEditing:NO animated:YES];
  [self hideEditingButtons];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"doneReordering" object:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
  
  NSMutableArray *folders = [_folders mutableCopy];
  Folder *folder = folders[sourceIndexPath.row];
  [folders removeObjectAtIndex:sourceIndexPath.row];
  [folders insertObject:folder atIndex:destinationIndexPath.row];
  _folders = [NSArray arrayWithArray:folders];
  
  tableView.delaysContentTouches = NO;
  [self saveAndReloadData:NO];
}

-(void)saveAndReloadData:(BOOL)reload{
  NSLog(@"Saving folders");
  NSData *foldersData = [NSKeyedArchiver archivedDataWithRootObject:_folders];
  [[NSUserDefaults standardUserDefaults] setObject:foldersData forKey:@"folders"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  NSLog(@"Saved");
  if (reload){
    [self.tableView reloadData];
  }
}

-(void)addFolder:(Folder*)folder atIndex:(NSInteger)index{
  NSMutableArray *temp = [_folders mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp insertObject:folder atIndex:index];
  _folders = [NSArray arrayWithArray:temp];
}

-(void)removeFolderAtIndex:(NSInteger)index{
  NSMutableArray *temp = [_folders mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp removeObjectAtIndex:index];
  _folders = [NSArray arrayWithArray:temp];
}

-(void)add{
  [self addFolder:[Folder new] atIndex:0];
  _editingName = YES;
  _editingCellIndex = 0;
  
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
  
  [self showEditingButtonsForNewRow:YES];
}

-(void)cancelCreation{
  [self hideEditingButtons];
  self.editingName = NO;
  [self removetextField];
  [self removeFolderAtIndex:0];
  [self deleteRowAtIndex:0];
}

-(void)removetextField{
  _nameField.text = @"";
  [_nameField removeFromSuperview];
  for (UITableViewCell *cell in self.tableView.visibleCells) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
}

-(void)deleteRowAtIndex:(NSInteger)index{
  [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)doneRenaming{
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_editingCellIndex inSection:0]];
  NSString *oldName = cell.textLabel.text;
  NSString *newName = _nameField.text;
  [self removetextField];
  [self hideEditingButtons];
  if (!newName || [newName isEqualToString:oldName] || [newName isEqualToString:@""]){
    return;
  }
  
  Folder *folder = _folders[_editingCellIndex];
  folder.name = newName;
  [self saveAndReloadData:YES];
}

-(void)doneAdding{
  NSString *name = _nameField.text;
  self.editingName = NO;
  [self removetextField];
  
  Folder *folder = _folders[0];
  folder.name = name;
  
  [self saveAndReloadData:YES];
  [self hideEditingButtons];
}

-(void)cancelRenaming{
  [self removetextField];
  [self hideEditingButtons];
}

-(void)showEditingButtonsForNewRow:(BOOL)forNewRow{
  _editingControlsAreForNewRow = forNewRow;
  [_cancelButton setAction: forNewRow ? @selector(cancelCreation) : @selector(cancelRenaming)];
  [_doneButton setAction: forNewRow ? @selector(doneAdding) : @selector(doneRenaming)];
  self.navigationItem.leftBarButtonItem = _cancelButton;
  self.navigationItem.rightBarButtonItem = _doneButton;
  _doneButton.enabled = NO;
}

-(void)hideEditingButtons{
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = _plusButton;
}

-(void)renameCellAtIndexPath:(NSIndexPath*)indexPath{
  self.editing = YES;
  _editingCellIndex = indexPath.row;
  [self showEditingButtonsForNewRow:NO];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [self addTextFieldToCell:cell];
}

-(void)addTextFieldToCell:(UITableViewCell*)cell{
  cell.accessoryType = UITableViewCellAccessoryNone;
  [cell addSubview:_nameField];
  CGRect frame = cell.bounds;
  frame.origin.x = 15;
  frame.origin.y += 1;
  frame.size.width -= 25;
  frame.size.height -= 2;
  _nameField.frame = frame;
  if (cell.textLabel.text.length > 0){
    _nameField.text = cell.textLabel.text;
  }
  [_nameField becomeFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:@"ListsCell" forIndexPath:indexPath];
  
  Folder *folder = _folders[indexPath.row];
  
  cell.textLabel.text = folder.name;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  [cell enableFolderIcon];
  
  if (indexPath.row == _editingCellIndex){
    if (_editingName){
      [self addTextFieldToCell:cell];
    }
  }
  return cell;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
  NSString *renameTitle = NSLocalizedString(@"renameTitle", nil);
  NSString *deleteTitle = NSLocalizedString(@"deleteTitle", nil);
  UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                          title:renameTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                            [self renameCellAtIndexPath:indexPath];
                                                                            tableView.editing = NO;
                                                                          }];
  UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                          title:deleteTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                            [self removeFolderAtIndex:indexPath.row];
                                                                            [self saveAndReloadData:NO];
                                                                            [self deleteRowAtIndex:indexPath.row];
                                                                          }];
  return @[deleteAction, renameAction];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NotebooksTVC *notebooks = [self.storyboard instantiateViewControllerWithIdentifier:@"notebooksTVC"];
  notebooks.folder = _folders[indexPath.row];
  notebooks.navigationItem.title = notebooks.folder.name;
  [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"lastFolder"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self.navigationController pushViewController:notebooks animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
  return UITableViewCellEditingStyleDelete;
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

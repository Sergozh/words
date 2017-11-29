

#import "NotebooksTVC.h"
#import "Notebook.h"
#import "WordsTVC.h"

@interface NotebooksTVC () <UITextFieldDelegate>

@property UITextField *nameField;

@property UIBarButtonItem *plusButton;
@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *cancelButton;

@property BOOL editingName;
@property NSInteger editingCellIndex;
@property Notebook *notebook;
@property BOOL editingControlsAreForNewRow;

@end

@implementation NotebooksTVC

-(void)awakeFromNib{
  [super awakeFromNib];
  
  _nameField = [[UITextField alloc] init];
  _nameField.placeholder = NSLocalizedString(@"newNotebookName", nil);
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
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reorder) name:@"reorderPlease" object:nil];
  
  if (animated){
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastNotebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return;
  }
  
  BOOL launchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchedBefore"];
  if (!launchedBefore){
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastNotebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastNotebook"];
  if (num){
    if (self.folder.notebooks.count > [num integerValue]){
      
      Notebook *notebook = _folder.notebooks[[num integerValue]];
      WordsTVC *words = [self.storyboard instantiateViewControllerWithIdentifier:@"wordsTVC"];
      
      words.notebook = notebook;
      words.navigationItem.title = notebook.name;
      NSLog(@"Notebooks tvc pusing new Words tvc in view will appear because there is a lastNotebook Key in defaults");
      [self.navigationController pushViewController:words animated:NO];
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
  
  NSMutableArray *notebooks = [_folder.notebooks mutableCopy];
  Notebook *notebook = notebooks[sourceIndexPath.row];
  [notebooks removeObjectAtIndex:sourceIndexPath.row];
  [notebooks insertObject:notebook atIndex:destinationIndexPath.row];
  _folder.notebooks = [NSArray arrayWithArray:notebooks];
  
  tableView.delaysContentTouches = NO;
  [self saveAndReloadData:NO];
}

-(void)saveAndReloadData:(BOOL)reload{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"saveFolders" object:nil];
  if (reload){
    [self.tableView reloadData];
  }
}

-(void)addNotebook:(Notebook*)notebook atIndex:(NSInteger)index{
  NSMutableArray *temp = [_folder.notebooks mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp insertObject:notebook atIndex:index];
  _folder.notebooks = [NSArray arrayWithArray:temp];
}

-(void)removeNotebookAtIndex:(NSInteger)index{
  NSMutableArray *temp = [_folder.notebooks mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp removeObjectAtIndex:index];
  _folder.notebooks = [NSArray arrayWithArray:temp];
}

-(void)add{
  [self addNotebook:[Notebook new] atIndex:0];
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
  [self removeNotebookAtIndex:0];
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

  Notebook *notebook = _folder.notebooks[_editingCellIndex];
  notebook.name = newName;
  [self saveAndReloadData:YES];
}

-(void)doneAdding{
  
  NSString *name = _nameField.text;
  self.editingName = NO;
  [self removetextField];
  
  Notebook *notebook = _folder.notebooks[0];
  notebook.name = name;
  
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
  return _folder.notebooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListsCell" forIndexPath:indexPath];
  
  Notebook *notebook = _folder.notebooks[indexPath.row];
  
  cell.textLabel.text = notebook.name;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
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
      [self removeNotebookAtIndex:indexPath.row];
      [self saveAndReloadData:NO];
      [self deleteRowAtIndex:indexPath.row];
  }];
  return @[deleteAction, renameAction];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
  WordsTVC *words = (WordsTVC*)[segue destinationViewController];
  if (![words isKindOfClass:[WordsTVC class]]){
    return;
  }
  words.notebook = _folder.notebooks[indexPath.row];
  words.navigationItem.title = words.notebook.name;
  
  [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"lastNotebook"];
  [[NSUserDefaults standardUserDefaults] synchronize];
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






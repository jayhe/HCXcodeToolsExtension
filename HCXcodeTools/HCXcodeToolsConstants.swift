//
//  HCXcodeToolsConstants.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation

let kSourceEditorClassName = "HCXcodeTools.SourceEditorCommand"
let kAddLazyCodeIdentifier = "com.he.HCXcodeToolsExtension.HCXcodeTools.AddLazyCode"
let kAddLazyCodeName = "AddLazyCode"
let kInitViewIdentifier = "com.he.HCXcodeToolsExtension.HCXcodeTools.InitView"
let kInitViewName = "InitVIew"
let kAddImportIdentifier = "com.he.HCXcodeToolsExtension.HCXcodeTools.AddImport"
let kAddImportName = "AddImport"
let kSortImportsIdentifier = "com.he.HCXcodeToolsExtension.HCXcodeTools.SortImports"
let kSortImportsName = "SortImports"

let kImplementation = "@implementation"
let kInterface = "@interface"
let kEnd = "@end"
let kUIView =  "UIView"
let kUIButton =  "UIButton"
let kUILabel =  "UILabel"
let kYYLabel =  "YYLabel"
let kUITextField =  "UITextField"
let kUITextView =  "UITextView"
let kUIScrollView =  "UIScrollView"
let kUITableView =  "UITableView"
let kUICollectionView =  "UICollectionView"
let kUIImageView =  "UIImageView"
let kGetterSetterPragmaMark = "#pragma mark - Getter && Setter"

/******************************* initView ******************************************/
let kInitViewExtensionCode = "@interface %@ ()\n\n\n\n@end\n"
let kInitViewLifeCycleCode = "\n- (instancetype)initWithFrame:(CGRect)frame {\n    self = [super initWithFrame:frame];\n    if (self) {\n        [self loadSubviews];\n    }\n    return self;\n}\n\n- (void)loadSubviews {\n\n}\n\n#pragma mark - Public Methods\n\n#pragma mark - Private Methods\n\n#pragma mark - Getter && Setter"

let kInitTableViewCellLifeCycleCode = "\n- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {\n    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];\n    if (self) {\n        [self loadSubviews];\n    }\n    return self;\n}\n\n- (void)loadSubviews {\n    self.selectionStyle = UITableViewCellSelectionStyleNone;\n}\n\n- (void)fillData:(id)data {\n\n\n}"

let kInitTableViewHeaderFooterViewLifeCycleCode = "\n- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {\n    self = [super initWithReuseIdentifier:reuseIdentifier];\n    if (self) {\n        [self loadSubviews];\n    }\n    return self;\n}\n\n- (void)loadSubviews {\n}\n\n- (void)fillData:(id)data {\n\n\n}"

let kInitViewControllerLifeCycleCode = "\n#pragma mark - Life Cycle\n\n- (void)viewDidLoad {\n    [super viewDidLoad];\n    [self setupUI];\n    [self configData];\n}\n\n- (void)viewWillAppear:(BOOL)animated {\n    [super viewWillAppear:animated];\n\n}\n\n#pragma mark - Public Methods\n\n#pragma mark - Setup View / Data\n\n- (void)setupUI {\n\n}\n\n- (void)configData {\n\n}\n\n#pragma mark - Observer\n\n#pragma mark - Notification\n\n#pragma mark - Action\n\n#pragma mark - Override Methods\n\n#pragma mark - Delegate\n\n#pragma mark - Private Methods\n\n#pragma mark - Network \n\n#pragma mark - Getter && Setter"

/*******************************  addlazyCode  ******************************************/
//自定义内容格式


let kAddLazyCodeTableViewDataSourceAndDelegate = "\n#pragma mark - UITableViewDataSource\n\n- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n    return 5;\n}\n\n- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@\"UITableViewCell\"];\n    if (indexPath.row % 2 == 0) {\n        cell.contentView.backgroundColor = [UIColor blueColor];\n     } else {\n        cell.contentView.backgroundColor = [UIColor redColor];\n    }\n    return cell;\n}\n\n#pragma mark - UITableViewDelegate\n\n- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {\n    return 60;\n}\n\n- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {\n\n}"

let kAddLazyCodeUICollectionViewDelegate = "#pragma mark - UICollectionViewDataSource\n\n- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {\n    return 0;\n}\n\n- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {\n    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@\"UICollectionViewCell\" forIndexPath:indexPath];\n    return cell;\n}\n\n#pragma mark - UICollectionViewDelegate\n\n- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {\n\n}"

let kAddLazyCodeUIScrollViewDelegate = "#pragma mark - UIScrollviewDelegate\n\n- (void)scrollViewDidScroll:(UIScrollView *)scrollView {\n\n\n}"

let kLazyCommonCode = "\n- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n    }\n    return _%@;\n}"

let kLazyUIViewCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero];\n        _%@.backgroundColor = [UIColor whiteColor];\n    }\n    return _%@;\n}"

let kLazyImageViewCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithImage:nil];\n        _%@.contentMode = UIViewContentModeScaleAspectFill;\n        _%@.clipsToBounds = YES;\n    }\n    return _%@;\n}"

let kLazyLabelCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero];\n        _%@.textAlignment = NSTextAlignmentLeft;\n        _%@.textColor = [UIColor blackColor];\n        _%@.font = [UIFont systemFontOfSize:18];\n        _%@.text = @\"test\";\n    }\n    return  _%@;\n}"

let kLazyYYLabelCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero];\n        _%@.textAlignment = NSTextAlignmentLeft;\n        _%@.textColor = [UIColor blackColor];\n        _%@.font = [UIFont systemFontOfSize:18];\n        _%@.text = @\"test\";\n    }\n    return  _%@;\n}"

let kLazyButtonCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [%@ buttonWithType:UIButtonTypeCustom];\n        [_%@ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];\n        _%@.titleLabel.font = [UIFont systemFontOfSize:14];\n        [_%@ setTitle:@\"test\" forState:UIControlStateNormal];\n        [_%@ addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];\n    }\n    return _%@;\n}"

let kLazyScrollViewCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n        _%@.alwaysBounceVertical = YES;\n        _%@.backgroundColor = [UIColor lightGrayColor];\n        _%@.delegate = self;\n    }\n    return _%@;\n}\n"

let kLazyUITableViewCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];\n        _%@.delegate = self;\n        _%@.dataSource = self;\n        _%@.backgroundColor = [UIColor whiteColor];\n        _%@.separatorStyle = UITableViewCellSeparatorStyleNone;\n        if (@available(iOS 11.0, *)) {\n            _%@.estimatedRowHeight = 0;\n            _%@.estimatedSectionFooterHeight = 0;\n            _%@.estimatedSectionHeaderHeight = 0;\n            _%@.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;\n        }\n        [_%@ registerClass:[UITableViewCell class] forCellReuseIdentifier:@\"UITableViewCell\"];\n    }\n    return _%@;\n}\n"

let kLazyUICollectionViewCode = "- (%@ *)%@ {\n    if (!_%@) {\n        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];\n        layout.itemSize = CGSizeMake(10, 10);\n        layout.minimumLineSpacing = 0;\n        layout.minimumInteritemSpacing = 0;\n        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;\n\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero collectionViewLayout:layout];\n        _%@.dataSource = self;\n        _%@.delegate = self;\n        [_%@ registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@\"UICollectionViewCell\"];\n    }\n    return _%@;\n}"

let kLazyUITextFieldCode = "- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n        _%@.borderStyle = UITextBorderStyleNone;\n        _%@.clearButtonMode = UITextFieldViewModeWhileEditing;\n        _%@.returnKeyType = UIReturnKeySearch;\n        _%@.font = [UIFont systemFontOfSize:14];\n        _%@.textColor = [UIColor blackColor];\n        _%@.placeholder = @\"test\";\n    }\n    return _%@;\n}"

let kLazyUITextViewCode = "- (%@ *)%@ {\n    if (_%@ == nil) {\n        _%@ = [[%@ alloc] init];\n        _%@.backgroundColor = [UIColor whiteColor];\n        _%@.textColor = [UIColor blackColor];\n        _%@.font = [UIFont systemFontOfSize:14];\n        _%@.textContainerInset = UIEdgeInsetsMake(9, 9, 9, 9);\n        _%@.layer.cornerRadius = 6;\n        _%@.clipsToBounds = YES;\n        _%@.delegate = self;\n    }\n    return _%@;\n}"

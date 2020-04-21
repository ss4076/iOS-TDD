#import <XCTest/XCTest.h>
#import "LoginPresenter.h"
#import "LoginConstants.h"
#import "FakeLoginModel.h"
#import "LoingInputValidator.h"
@import OCHamcrest;
@import OCMockito;


@interface Admin_StandardTests: XCTestCase
{
    LoginPresenter *presenter;
    id<View>view;
    id<Model>repository;
}

//@property (nonatomic, strong) MockLoginModel *mockLoginModel;
@end

@implementation Admin_StandardTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    view = mockProtocol(@protocol(View));
    repository = mockProtocol(@protocol(Model));
    
    presenter = [[LoginPresenter alloc] initWithView:view withRepository:repository];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

/*
     presenter.onClickCompanyList();
 
 
     // ID 저장 체크박스 선택
     when(repository.getUserIdSavedStatus()).thenReturn(true);
     // fake repository와 로그인 시도(LoginModelTest에서 input값 유효성 검증 함)
     presenter.onClickTestLogin();
     // 로딩 팝업 보여주기
     inOrder.verify(view).showLoadingDialog();
     // 키패드 숨김
     inOrder.verify(view).hideSoftKeyboard();
 
     String id = view.getInputID();
     String pwd = view.getInputPW();
     String companyKey = view.getCompanyKey();

     // repository의 testLogin 함수 호출, 결과 콜백인터페이스 함께 넘김)
     inOrder.verify(repository).testLogin(eq(id),eq(pwd),eq(companyKey), loginResultListener.capture());
 
     // 성공 콜백 호출
     loginResultListener.getValue().onSuccess(mockUserInfo);
     // id 값 저장
     inOrder.verify(repository).setSavedUserId(anyString());
     // ID 저장 체크박스 선택했으로 입력된 id/pw 초기화
     inOrder.verify(view).clearInputText();
     // 로딩 팝업 숨김
     inOrder.verify(view).hideLoadingDialog();
 */

- (void)testValidData {
    
    [given([view getInputID]) willReturn:@"admin"];
    [given([view getInputPW]) willReturn:@"1234sd5"];
    [given([view getCompanyKey]) willReturn:@"1"];
    XCTAssertTrue([LoingInputValidator isValidData:[view getInputID]]);
    XCTAssertTrue([LoingInputValidator isValidData:[view getInputPW]]);
    XCTAssertTrue([LoingInputValidator isValidData:[view getCompanyKey]]);
}



/*
 
 [loginView showClearServerInfoOnCompleted:^(NSString *domainStr) {
 NSLog(@"clearServerInfo onCompleted");
 [self->loginModel resetServerInfo:domainStr onCompleted:^{
 NSLog(@"resetServerInfo onCompleted");
 [self->loginView restartApplication];
 }];
 } withOnCancelled:^{
 // do nothing...
 NSLog(@"resetServerInfo withOnCancelled");
 }];
 
 */
- (void) testResetServerInfo {
    
    [presenter clearServerInfo];
    
    HCArgumentCaptor *viewOnCompleted = [[HCArgumentCaptor alloc] init];
    HCArgumentCaptor *viewOnCanceled = [[HCArgumentCaptor alloc] init];
    
    [verify(view) showClearServerInfoOnCompleted:(id)viewOnCompleted withOnCancelled:(id)viewOnCanceled];
    __block void(^view_OnCompleted)(NSString *domainStr) = viewOnCompleted.value;
    view_OnCompleted(anything());
    
    
    HCArgumentCaptor *modelOnCompleted = [[HCArgumentCaptor alloc] init];
    [[verify(repository) withMatcher:anything() forArgument:0] resetServerInfo:anything() onCompleted:(id)modelOnCompleted];
    __block void(^model_completed)(void) = modelOnCompleted.value;
    model_completed();

    [verify(view) restartApplication];
}

- (void)testLoginFail {
    
    // stubbing
    [given([view getInputID]) willReturn:@"a"];
    [given([view getInputPW]) willReturn:@"1234sd5"];
    [given([view getCompanyKey]) willReturn:@"1"];
    
    
    XCTAssertEqual([view getInputID], @"a");
    XCTAssertEqual([view getInputPW], @"1234sd5");
    XCTAssertEqual([view getCompanyKey], @"1");
    
    [verify(view) getInputID];
    [verify(view) getInputPW];
    [verify(view) getCompanyKey];
    
    // 호출
    [presenter login];
    
    [verify(view) showLoadingDialog];
    [verify(view) hideSoftKeyboard];
    
    HCArgumentCaptor *successCaptor = [[HCArgumentCaptor alloc] init];
    HCArgumentCaptor *failCaptor = [[HCArgumentCaptor alloc] init];
    
    [[[[verify(repository)
        withMatcher:anything() forArgument:0]
        withMatcher:anything() forArgument:1]
        withMatcher:anything() forArgument:2]
        doLogin:@"admin" withPassword:@"12345" withCompanyKey:@"1" withSuccess:(id)successCaptor withFail:(id)failCaptor];
    
    
    __block void(^fail)(int errorCode, NSString *message) = failCaptor.value;
    fail(401,@"error");
    
    [verify(view) clearInputText];
    [verify(view) hideLoadingDialog];
    [verify(view) showErrorDialog:401 withErrMessage:@"error"];
}


- (void)testLoginSuccess {
    
    // stubbing
    [given([view getInputID]) willReturn:@"admin"];
    [given([view getInputPW]) willReturn:@"12345"];
    [given([view getCompanyKey]) willReturn:@"1"];
    
    XCTAssertEqual([view getInputID], @"admin");
    XCTAssertEqual([view getInputPW], @"12345");
    XCTAssertEqual([view getCompanyKey], @"1");
    
    [verify(view) getInputID];
    [verify(view) getInputPW];
    [verify(view) getCompanyKey];
    
    // 호출
    [presenter login];
    
    [verify(view) showLoadingDialog];
    [verify(view) hideSoftKeyboard];
    
    HCArgumentCaptor *successCaptor = [[HCArgumentCaptor alloc] init];
    HCArgumentCaptor *failCaptor = [[HCArgumentCaptor alloc] init];
    
    [[[[verify(repository)
        withMatcher:anything() forArgument:0]
        withMatcher:anything() forArgument:1]
        withMatcher:anything() forArgument:2]
        doLogin:@"admin" withPassword:@"12345" withCompanyKey:@"1" withSuccess:(id)successCaptor withFail:(id)failCaptor];
    
    __block void(^success)(void) = successCaptor.value;
    success();
    
    [verify(repository) setSavedAdminId:anything()];
//    // ID 저장 체크박스 선택했으로 입력된 id/pw 초기화
//    
    [verify(view) clearInputText];
//    // 로딩 팝업 숨김
    [verify(view) hideLoadingDialog];
    // 메인화면(메뉴)으로 이동
    [verify(view) moveToMenuView];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

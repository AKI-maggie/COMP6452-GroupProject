pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "./UserITF.sol";
import "remix_accounts.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract UserITFTest is UserITF {
    address acc0;
    address acc1;
    address acc2;
    
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }
    
    /**
     * Basic Register
     **/
    function validRegister() public {
        Assert.equal(register('Alice'), true, 'Should be a succssful register');
    }
    
    function dupRegister() public {
        Assert.equal(register('Tom'), true, 'should not accept duplicate register for the same account');
    }
    
    /// #sender: account-1
    function blankRegister() public {
        Assert.equal(register(''), true, 'should not accept blank username register');
    }
     
    /** 
     * UseCase 1
     **/
    function validNewReview() public {
        Assert.equal(newReview('testReceipt', 'testRes', 'This is a good restaurant!'), 0, 'A successful review upload with 0 initial credits');
    }
    
    /// #sender: account-1
    function invalidUserReview() public {
        Assert.equal(newReview('testReceipt2', 'testRes', 'This is a spam'), 0, 'A unofficial user could not make reviews');
    }
    
    function blankNewReview() public {
        Assert.equal(newReview('', 'testRes', 'This is a good restaurant!'), 0, 'Review could not be uploaded without a receipt');
    }
    
    function blankNewReview2() public {
        Assert.equal(newReview('testReceipt', '', 'This is a good restaurant!'), 0, 'Must specify a restaurant');
    }
    
    function blankNewReview3() public {
        Assert.equal(newReview('testReceipt', 'testRes', ''), 0, 'Must write something for the review');
    }
    
    // function dupNewReview() public {
    //     Assert.equal(newReview('testReceipt', 'testRes', 'This is a good restaurant again!'), 0, 'Duplicate use of receipt is not allowed');
    // }
    
    // function invalidReceiptReview() public {
    //     Assert.equal(newReview('invalidReceipt', 'testRes', "I didn't go there"), 0, 'Review with an invalid receipt proof is not available');
    // }
    
    function 
    
}

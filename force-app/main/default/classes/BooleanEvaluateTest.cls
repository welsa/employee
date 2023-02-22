@istest
public class BooleanEvaluateTest {
    static testMethod void evaluateExpressionTest(){
        test.startTest();
        //BooleanEvaluate classBool = new BooleanEvaluate();
        BooleanEvaluate.evaluateExpression('false AND (false OR (true AND (false OR true)))');
        test.stopTest();
    }
}
public with sharing class BooleanEvaluate {

    public static boolean evaluateExpression(String expression){
        system.debug(expression.containsIgnoreCase('false')+'__'+expression.containsIgnoreCase('true'));
        if(expression.containsIgnoreCase('false') == false){ return true;}
        if(expression.containsIgnoreCase('true') == false){ return false;}
        expression = runeval(expression);
        if(expression == 'true') return true;
        return false;
    }
    
    public static string runeval(String expression){
        if(expression.contains('true AND true')||expression.contains('true AND false')||expression.contains('false AND true')||expression.contains('false AND false')){
            expression = BooleanEvaluate.replaceANDLogic(expression);
        }
        if(expression.contains('true OR true')||expression.contains('true OR false')||expression.contains('false OR true')||expression.contains('false OR false')){
            expression = BooleanEvaluate.replaceORLogic(expression);
        }
        system.debug(expression+'___');   
        if(expression.contains('(true)')){     
            expression = replaceleftBrackets(expression);
        }
        if(expression.contains('(false)')){
            expression = replaceRightBrackets(expression);
        }
        system.debug(expression+'___');
        if(expression.contains('(')|| expression.contains(')') || expression.contains('OR')|| expression.contains('AND')){
            expression = runeval(expression);
        }
        system.debug(expression+'___final');
        return expression;
    }
        
    public static string replaceleftBrackets(string expression){
        expression = expression.replaceAll('\\(true\\)', 'true');
        if(expression.contains('(true)')){
            expression = replaceRightBrackets(expression);
        }
        return expression;
    }
    public static string replaceRightBrackets(string expression){
        expression = expression.replaceAll('\\(false\\)', 'false');
        if(expression.contains('(false)')){
            expression = replaceRightBrackets(expression);
        }
        return expression;
    }
    
    public static string replaceANDLogic(String exp){
        exp = exp.replaceAll('true AND true', 'true');
        exp = exp.replaceAll('false AND true', 'false');
        exp = exp.replaceAll('true AND false', 'false');
        exp = exp.replaceAll('false AND false', 'false');
        if(exp.contains('true AND true')||exp.contains('true AND false')||exp.contains('false AND true')||exp.contains('false AND false')){
            exp = replaceANDLogic(exp);
        }        
        return exp;
    }
    public static string replaceORLogic(String exp){
        exp = exp.replaceAll('true OR true', 'true');
        exp = exp.replaceAll('false OR true', 'true');
        exp = exp.replaceAll('true OR false', 'true');
        exp = exp.replaceAll('false OR false', 'false');
        if(exp.contains('true OR true')||exp.contains('true OR false')||exp.contains('false OR true')||exp.contains('false OR false')){
            system.debug('ayub___');
            exp = replaceORLogic(exp);
        }
        return exp;
    }
}
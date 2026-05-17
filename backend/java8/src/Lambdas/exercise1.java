package Lambdas;
@FunctionalInterface
interface MathOperation{
    int operate(int a,int b);
}
public class exercise1 {

    public static void main(String[] args) {
        MathOperation addition=(a,b)->a+b;
        MathOperation multiplication=(a,b)->a*b;

        int num1=10;
        int num2=5;

        System.out.println(num1 + "+" + num2 +"="+addition.operate(num1,num2));
    }
}

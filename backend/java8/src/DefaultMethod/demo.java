package DefaultMethod;


interface A{
    default void sayhello(){
        System.out.println("hello A");
    }
}
interface B{
    default void sayhello(){
        System.out.println("hello B");
    }
}

public class demo implements A,B {
    @Override
    public void sayhello(){
        A.super.sayhello();
    }
    public static void main(String[] args){
        demo demo=new demo();
        demo.sayhello();
    }
}

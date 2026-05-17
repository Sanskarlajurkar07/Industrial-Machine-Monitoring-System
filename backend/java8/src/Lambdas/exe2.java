package Lambdas;
import java.util.*;
public class exe2 {
    public static void main(String[] args) {
        List<String> names =Arrays.asList("Sanskar","Aai","Nomesh");
        names.sort((a,b)-> a.length()-b.length());
        System.out.println(names);
    }
}

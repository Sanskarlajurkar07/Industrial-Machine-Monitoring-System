package DefaultMethod;

import com.sun.jdi.PathSearchingVirtualMachine;

interface MessagingApp{
  void sendMessage(String msg);
  default void sendVideo(String videoName){
      System.out.println("Sending video" + videoName);
  }
}
public class WhatsApp implements MessagingApp {
    @Override
    public void sendMessage(String msg){
        System.out.println("sending video" + msg);
    }
    public static void main(String[] args) {
        WhatsApp obj =new WhatsApp();
        obj.sendVideo("video1");
        obj.sendMessage("hello");
    }
}

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package de.bergischweb.simulation.helper;

import org.jruby.Ruby;
import org.jruby.RubyInteger;
import org.jruby.RubyObject;
import org.jruby.runtime.builtin.IRubyObject;

/**
 *
 * @author jthoenes
 */
public class JRubyHelper {
   private Ruby ruby;
   private JRubyHelper(){};

   private static JRubyHelper instance;

   public static synchronized JRubyHelper getInstance(){
      if(instance == null){
         instance = new JRubyHelper();
      }
      return instance;
   }

   public static Ruby ruby(){
      return getInstance().getRuby();
   }

   public Ruby getRuby() {
      return this.ruby;
   }

   public void initRuby(RubyObject ro){
      this.ruby = ro.getRuntime();
   }


   public int capacity(){
      return runCount();
   }

   public int threadCapacity(){
      return runCount()/Runtime.getRuntime().availableProcessors() + Runtime.getRuntime().availableProcessors();
   }

   private int runCount(){
      IRubyObject o = this.ruby.getModule("Sim")
            .getClass("Config")
            .callMethod(ruby.getCurrentContext(), "instance")
            .callMethod(ruby.getCurrentContext(), "runs");
      return RubyInteger.fix2int(o);
   }

}

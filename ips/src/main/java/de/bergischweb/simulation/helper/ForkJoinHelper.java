package de.bergischweb.simulation.helper;

import jsr166y.ForkJoinPool;
import jsr166y.ForkJoinTask;

/**
 *
 * @author jthoenes
 */
public class ForkJoinHelper {

   private static ForkJoinHelper instance = null;
   private ForkJoinPool executer;

   private ForkJoinHelper() {
      executer = new ForkJoinPool(Runtime.getRuntime().availableProcessors());
   }

   public static ForkJoinHelper forkJoinHelper() {
      return getInstance();
   }

   public static synchronized ForkJoinHelper getInstance() {
      if (instance == null) {
         instance = new ForkJoinHelper();
      }
      return instance;
   }

   public ForkJoinPool getPool(){
      return executer;
   }

   public void execute(ForkJoinTask task) {
      executer.invoke(task);
   }
}

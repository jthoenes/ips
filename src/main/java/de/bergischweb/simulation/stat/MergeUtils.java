/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package de.bergischweb.simulation.stat;

/**
 *
 * @author jthoenes
 */
public class MergeUtils {
   public static double[] merge(double[]... args){
      int size = 0;
      for(int i=0; i<args.length; i++){
         size += args[i].length;
      }

      double[] merged = new double[size];
      int start = 0;
      for(int i=0; i<args.length; i++){
         System.arraycopy(args[i], 0, merged, start, args.length);
         start += args[i].length;
      }
      return merged;
   }
}

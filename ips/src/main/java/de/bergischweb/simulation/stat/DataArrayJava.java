package de.bergischweb.simulation.stat;

import org.apache.commons.math.stat.StatUtils;
import org.apache.commons.math.stat.descriptive.rank.Median;
import org.apache.commons.math.util.DoubleArray;
import org.apache.commons.math.util.ResizableDoubleArray;

/**
 *
 * @author jthoenes
 */
public class DataArrayJava {

   DoubleArray samples = new ResizableDoubleArray();

   public DataArrayJava() {
   }

   public void addSamples(double[] _subsample) {
      for (double s : _subsample) {
         samples.addElement(s);
      }
   }

   public double getMeanJava() {
      return StatUtils.mean(samples.getElements());
   }

   public double getVarianceJava() {
      return StatUtils.variance(samples.getElements());
   }

   public double getMedianJava() {
      return new Median().evaluate(samples.getElements());
   }

   public double getSize(){
      return samples.getNumElements();
   }
}

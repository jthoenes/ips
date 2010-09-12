/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package de.bergischweb.simulation.stat;

import java.util.List;
import java.util.ArrayList;
import org.apache.commons.math.stat.StatUtils;
import org.apache.commons.math.stat.descriptive.rank.Median;
import org.apache.commons.math.util.DoubleArray;
import org.apache.commons.math.util.ResizableDoubleArray;
import org.jruby.RubyArray;

import static de.bergischweb.simulation.helper.JRubyHelper.ruby;

/**
 *
 * @author jthoenes
 */
public class DataJava {

   private DoubleArray samples = new ResizableDoubleArray();
   private List<Object> subsamples = new ArrayList<Object>();

   public DataJava() {
   }

   public void addSamples(double[] _subsample) {
      for (double s : _subsample) {
         samples.addElement(s);
      }
      subsamples.add(_subsample);
   }

   public RubyArray getSamplesJava() {
      RubyArray ary = RubyArray.newArray(ruby(), samples.getNumElements());
      for (double v : samples.getElements()) {
         ary.add(v);
      }
      return ary;
   }

   public RubyArray getSubsamplesJava() {
      RubyArray ary = RubyArray.newArray(ruby(), subsamples.size());
      for (int i = 0; i < subsamples.size(); i++) {
         RubyArray subary = RubyArray.newArray(ruby(), ((double[]) subsamples.get(i)).length);
         for (double v : (double[]) subsamples.get(i)) {
            subary.add(v);
         }
         ary.add(subary);
      }
      return ary;
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

   public double getSize() {
      return samples.getNumElements();
   }
}

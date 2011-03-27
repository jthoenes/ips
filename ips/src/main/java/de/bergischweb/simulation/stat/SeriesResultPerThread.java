/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package de.bergischweb.simulation.stat;

import de.bergischweb.simulation.helper.JRubyHelper;
import gnu.trove.TDoubleArrayList;
import gnu.trove.TObjectIntHashMap;
import java.util.HashMap;
import java.util.Map;
import org.jruby.RubySymbol;

/**
 *
 * @author jthoenes
 */
public class SeriesResultPerThread {

   private TObjectIntHashMap booleanTrues;
   private TObjectIntHashMap booleanCounts;
   private Map<RubySymbol, TDoubleArrayList> doubleResults;

   public SeriesResultPerThread() {
      booleanTrues = new TObjectIntHashMap();
      booleanCounts = new TObjectIntHashMap();
      doubleResults = new HashMap<RubySymbol, TDoubleArrayList>();

   }

   void addBoolean(RubySymbol quantity, boolean value) {
      if (value) {
         if (!booleanTrues.containsKey(quantity)) {
            booleanTrues.put(quantity, 1);
         } else {
            booleanTrues.increment(quantity);
         }
      }

      if (!booleanCounts.containsKey(quantity)) {
         booleanCounts.put(quantity, 1);
      } else {
         booleanCounts.increment(quantity);
      }

   }

   void addDouble(RubySymbol quantity, double value) {
      TDoubleArrayList container = doubleResults.get(quantity);
      if (container == null) {
         container = new TDoubleArrayList(JRubyHelper.getInstance().threadCapacity());
         doubleResults.put(quantity, container);
      }
      container.add(value);
   }

   int getBooleanTrues(RubySymbol quantity) {
      return booleanTrues.get(quantity);
   }

   int getBooleanCount(RubySymbol quantity) {
      return booleanCounts.get(quantity);
   }

   TDoubleArrayList getDoubleResults(RubySymbol quantity) {
      return doubleResults.get(quantity);
   }
}

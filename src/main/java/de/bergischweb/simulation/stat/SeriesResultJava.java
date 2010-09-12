package de.bergischweb.simulation.stat;

import de.bergischweb.simulation.helper.JRubyHelper;
import static de.bergischweb.simulation.helper.ForkJoinHelper.forkJoinHelper;
import extra166y.ParallelDoubleArray;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.jruby.RubySymbol;

/**
 *
 * @author jthoenes
 */
public class SeriesResultJava {

   private Map<Thread, SeriesResultPerThread> threadResults;
   private Map<RubySymbol, List<Boolean>> booleanResults;
   private Map<RubySymbol, ParallelDoubleArray> doubleResults;
   private Map<RubySymbol, Boolean> doubleSortedFlag;

   private Map<RubySymbol, Double> meanCache;

   protected SeriesResultJava() {
      booleanResults = new HashMap<RubySymbol, List<Boolean>>();
      doubleResults = new HashMap<RubySymbol, ParallelDoubleArray>();
      threadResults = new HashMap<Thread, SeriesResultPerThread>();
      doubleSortedFlag = new HashMap<RubySymbol, Boolean>();

      meanCache = new HashMap<RubySymbol, Double>();
   }

   protected void addBoolean(RubySymbol quantity, boolean value) {
      threadResult().addBoolean(quantity, value);
   }

   protected void addDouble(RubySymbol quantity, double value) {
      threadResult().addDouble(quantity, value);
   }

  /* private List<Boolean> getBooleanResults(RubySymbol quantity) {
      List<Boolean> results = booleanResults.get(quantity);
      if (results == null) {
         results = new ArrayList<Boolean>(JRubyHelper.getInstance().capacity());
         for (SeriesResultPerThread threadResult : threadResults.values()) {
            results.addAll(threadResult.getBooleanResults(quantity));
         }
         assert(results.size() == JRubyHelper.getInstance().capacity());
         booleanResults.put(quantity, results);
      }
      return results;
   }*/

   private ParallelDoubleArray getDoubleResults(RubySymbol quantity) {
      ParallelDoubleArray results = doubleResults.get(quantity);
      if (results == null) {
         results = ParallelDoubleArray.createEmpty(JRubyHelper.getInstance().capacity(), forkJoinHelper().getPool());
         for (SeriesResultPerThread threadResult : threadResults.values()) {
            results.addAll(threadResult.getDoubleResults(quantity).toNativeArray());
         }
         assert(results.size() == JRubyHelper.getInstance().capacity());
         doubleResults.put(quantity, results);
      }
      return results;
   }

   private SeriesResultPerThread threadResult() {
      SeriesResultPerThread threadResult = threadResults.get(Thread.currentThread());
      if (threadResult == null) {
         threadResult = new SeriesResultPerThread();
         threadResults.put(Thread.currentThread(), threadResult);
      }
      return threadResult;
   }

   protected int calculateBooleans(RubySymbol quantity, boolean value) {
      int trues = 0;
      for (SeriesResultPerThread threadResult : threadResults.values()) {
         trues += threadResult.getBooleanTrues(quantity);
      }
      return value ? trues : calculateBooleanCount(quantity) - trues;
   }

   private int calculateBooleanCount(RubySymbol quantity) {
      int count = 0;
      for (SeriesResultPerThread threadResult : threadResults.values()) {
         count += threadResult.getBooleanCount(quantity);
      }
      return count;
   }

   protected double calculateQuantile(RubySymbol quantity, double p) {
      ParallelDoubleArray result = getDoubleSorted(quantity);
      // Copied from org.apache.commons.math.stat.descriptive.rank.Percentile
      int length = result.size();
      double n = (double) length;
      double pos = p * n;
      double fpos = Math.floor(pos);
      int intPos = (int) fpos;
      double dif = pos - fpos;

      if (pos < 1) {
         return result.get(0);
      }
      if (pos >= n) {
         return result.get(length - 1);
      }
      double lower = result.get(intPos);
      double upper = result.get(intPos + 1);
      return lower + dif * (upper - lower);
   }

   protected double calculateMean(RubySymbol quantity) {
      if(! meanCache.containsKey(quantity)){
         meanCache.put(quantity, getDoubleResults(quantity).summary().average());
      }
      return meanCache.get(quantity);
   }

   private ParallelDoubleArray getDoubleSorted(RubySymbol quantity) {
      ParallelDoubleArray ary = getDoubleResults(quantity);
      if (!doubleSortedFlag.containsKey(quantity)) {
         ary.sort();
         doubleSortedFlag.put(quantity, true);
      }
      return ary;
   }
}

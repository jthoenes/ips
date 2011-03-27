package de.bergischweb.simulation.rng;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 *
 * @author jthoenes
 */
public class GaussianValueServer {
   
   private Map<Thread, Random> randoms;


   public GaussianValueServer(){
      this.randoms = new HashMap<Thread, Random>();
   }

   private double mu = 0.0;
   private double sigma = 0.0;

   public double getMu() {
      return mu;
   }

   public void setMu(double mu) {
      this.mu = mu;
   }

   public double getSigma() {
      return sigma;
   }

   public void setSigma(double sigma) {
      this.sigma = sigma;
   }

   public double[] fill(int lenght) {
      double[] arry = new double[lenght];
      fill(arry);
      return arry;
   }

   public void fill(double[] ary) {
      for(int i = 0; i < ary.length; i++) {
         Random r = getRandom();
         ary[i] = r.nextGaussian() * sigma + mu;
      }
   }

   private Random getRandom() {
      Random r = randoms.get(Thread.currentThread());
      if(r == null){
         r = new Random();
         randoms.put(Thread.currentThread(), r);
      }
      return r;
   }
}

/*
 *  Copyright 2010 Johannes Th&ouml;nes <johannes.thoenes@googlemail.com>.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *  under the License.
 */

package de.bergischweb.ips;

import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

import java.io.IOException;

/**
 * The Main class for starting the scripts.
 *
 * @author Copyright 2010 Johannes Th&ouml;nes <johannes.thoenes@googlemail.com>
 */
public class Main {

  /**
   * The entry point into the simulation.
   * <p/>
   * Executes the Ruby Start Scripts. The first parameter is the name of the script.
   * The rest ist passed as parameter to the script.
   *
   * @param args Ignored
   */
  public static void main(String... args) throws IOException {
    ClassLoader classLoader = Main.class.getClassLoader();

    ScriptingContainer container = new ScriptingContainer();
    container.put("$CLASS_LOADER", container.getProvider().getRuntime().getJRubyClassLoader());
    container.runScriptlet(PathType.CLASSPATH, "scripts/test.rb");


  }
}

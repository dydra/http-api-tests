/* 
 The Dydra Sesame Compliance Test is licensedunder the [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
 "public domain" license.

  To the extent possible under law, [Datagraph GmbH](http://datagraph.org)
  has waived all copyright and related or neighboring rights to
  the Dydra Sesame Compliance Test.
*/

package org.openrdf.sail.dydra;

import java.io.IOException;

import org.junit.Rule;
import org.junit.rules.TemporaryFolder;

import org.openrdf.sail.InferencingTest;
import org.openrdf.sail.NotifyingSail;
import org.openrdf.sail.Sail;
import org.openrdf.sail.inferencer.fc.ForwardChainingRDFSInferencer;
// place-holding
import org.openrdf.sail.nativerdf.NativeStore;

public class DydraStoreInferencingTest extends InferencingTest {

	@Rule
	public TemporaryFolder tempDir = new TemporaryFolder();

	@Override
	protected Sail createSail() {
		try {
			NotifyingSail sailStack = new NativeStore(tempDir.newFolder("nativestore"), "spoc,posc");
			sailStack = new ForwardChainingRDFSInferencer(sailStack);
			return sailStack;
		}
		catch (IOException e) {
			throw new AssertionError(e);
		}
	}
}

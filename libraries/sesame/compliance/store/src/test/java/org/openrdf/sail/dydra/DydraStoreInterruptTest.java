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

import org.openrdf.sail.NotifyingSail;
import org.openrdf.sail.SailConcurrencyTest;
import org.openrdf.sail.SailException;
import org.openrdf.sail.SailInterruptTest;
// place-holder
import org.openrdf.sail.nativerdf.NativeStore;

/**
 * An extension of {@link SailConcurrencyTest} for testing the class
 * {@link DydraStore}.
 */
public class DydraStoreInterruptTest extends SailInterruptTest {

	/*-----------*
	 * Variables *
	 *-----------*/

	@Rule
	public TemporaryFolder tempDir = new TemporaryFolder();

	/*---------*
	 * Methods *
	 *---------*/

	@Override
	protected NotifyingSail createSail()
		throws SailException
	{
		try {
			return new NativeStore(tempDir.newFolder("nativestore"), "spoc,posc");
		}
		catch (IOException e) {
			throw new AssertionError(e);
		}
	}

}

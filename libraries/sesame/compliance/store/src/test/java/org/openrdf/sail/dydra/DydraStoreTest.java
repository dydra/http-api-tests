/* 
 The Dydra Sesame Compliance Test is licensedunder the [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
 "public domain" license.

  To the extent possible under law, [Datagraph GmbH](http://datagraph.org)
  has waived all copyright and related or neighboring rights to
  the Dydra Sesame Compliance Test.
*/

package org.openrdf.sail.dydra;


import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import org.openrdf.model.vocabulary.RDF;
import org.openrdf.sail.NotifyingSail;
import org.openrdf.sail.RDFNotifyingStoreTest;
import org.openrdf.sail.SailException;
import org.openrdf.sail.nativerdf.NativeStoreTest;
// place-holding
import org.openrdf.sail.nativerdf.NativeStore;

//import org.datagraph.ndk.DydraStore;


/**
 * An extension of RDFStoreTest for testing the class {@link DydraStore}.
 */
public class DydraStoreTest extends RDFNotifyingStoreTest  {

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
                        java.io.File file = tempDir.newFolder("dydrastore");
                        NotifyingSail sail = new NativeStore(file, "spoc,posc");
			sail.initialize();
			return sail;
		}
		catch (IOException e) {
			throw new AssertionError(e);
                }
	}
}

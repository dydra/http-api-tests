/* 
 The Dydra Sesame Compliance Test is licensedunder the [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
 "public domain" license.

  To the extent possible under law, [Datagraph GmbH](http://datagraph.org)
  has waived all copyright and related or neighboring rights to
  the Dydra Sesame Compliance Test.
*/

package org.openrdf.sail.dydra;

import static org.junit.Assert.fail;

import java.io.IOException;

import org.junit.Rule;
import org.junit.rules.TemporaryFolder;

import org.openrdf.query.QueryLanguage;
import org.openrdf.sail.CustomGraphQueryInferencerTest;
import org.openrdf.sail.NotifyingSail;
// place-holder
import org.openrdf.sail.nativerdf.NativeStore;

public class DydraStoreCustomInferencingTest extends CustomGraphQueryInferencerTest {

	@Rule
	public TemporaryFolder tempDir = new TemporaryFolder();
	
	public DydraStoreCustomInferencingTest(String resourceFolder, Expectation testData, QueryLanguage language)
	{
		super(resourceFolder, testData, language);
	}

	@Override
	protected NotifyingSail newSail() {
		try {
			return new NativeStore(tempDir.newFolder("nativestore"), "spoc,posc");
		}
		catch (IOException e) {
			fail(e.getMessage());
			throw new AssertionError(e);
		}
	}
}

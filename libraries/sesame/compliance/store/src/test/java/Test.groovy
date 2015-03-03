/*
 * a minimal manual test of the dydra sesame native store implementation
 *
 * runs specilized forms of those sesame compliance tests which exercise
 * aspects specific to the the dydra implementation
 */

import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.vocabulary.*;


import org.openrdf.sail.nativerdf.NativeStoreTest;
import org.openrdf.sail.nativerdf.NativeDydraStoreTest;

Result result = JUnitCore.runClasses(NativeStoreTest.class);
println result;
println result.wasSuccessful();
println result.getFailures();
//NativeDydraStoreTest ndst_test = new NativeDydraStoreTest();
//ndst_test.setUp();
//ndst_test.testGetNamespacePersistence();
//ndst_test.testNotifyingRemoveAndClear();



/* 
 The Dydra Sesame Compliance Test is licensedunder the [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
 "public domain" license.

  To the extent possible under law, [Datagraph GmbH](http://datagraph.org)
  has waived all copyright and related or neighboring rights to
  the Dydra Sesame Compliance Test.
*/

package org.openrdf.sail.dydra;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.util.Collection;
import java.util.List;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import info.aduna.iteration.Iterations;

import org.openrdf.model.Model;
import org.openrdf.model.Resource;
import org.openrdf.model.Statement;
import org.openrdf.model.URI;
import org.openrdf.model.Value;
import org.openrdf.model.ValueFactory;
import org.openrdf.model.impl.LinkedHashModel;
import org.openrdf.model.impl.ValueFactoryImpl;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.repository.util.RepositoryUtil;
import org.openrdf.rio.RDFFormat;
// place-holding
import org.openrdf.sail.nativerdf.NativeStore;

/**
 * Integration tests for checking Native Store index consistency.
 * 
 * @author Jeen Broekstra
 */
public class DydraStoreConsistencyTest {

	/*-----------*
	 * Variables *
	 *-----------*/

	@Rule
	public TemporaryFolder tempDir = new TemporaryFolder();

	/*---------*
	 * Methods *
	 *---------*/

	@Test
	public void testSES1867IndexCorruption() throws Exception {
		ValueFactory vf = ValueFactoryImpl.getInstance();
		URI oldContext = vf.createURI("http://example.org/oldContext");
		URI newContext = vf.createURI("http://example.org/newContext");

		File dataDir = tempDir.newFolder("dydrastore-consistency");
		
		Repository repo = new SailRepository(new NativeStore(dataDir, "spoc,psoc"));
		repo.initialize();

		RepositoryConnection conn = repo.getConnection();

		// Step1: setup the initial database state
		System.out.println("Preserving initial state ...");
		conn.add(getClass().getResourceAsStream("/nativestore-testdata/SES-1867/initialState.nq"), "",
				RDFFormat.NQUADS);
		System.out.println("Number of statements: " + conn.size());

		// Step 2: in a single transaction remove "oldContext", then add
		// statements to "newContext"
		conn.begin();

		System.out.println("Removing old context");
		conn.remove((Resource)null, (URI)null, (Value)null, oldContext);

		System.out.println("Adding updated context");
		conn.add(getClass().getResourceAsStream("/nativestore-testdata/SES-1867/newTriples.nt"), "",
				RDFFormat.NTRIPLES, newContext);
		conn.commit();

		// Step 3: check whether oldContext is actually empty
		List<Statement> stmts = Iterations.asList(conn.getStatements(null, null, null, false, oldContext));
		System.out.println("Not deleted statements: " + stmts.size());

		conn.close();
		repo.shutDown();

		// Step 4: check the repository size with SPOC only
		new File(dataDir, "triples.prop").delete(); // delete triples.prop to
																	// update index usage
		repo = new SailRepository(new NativeStore(dataDir, "spoc"));
		repo.initialize();
		conn = repo.getConnection();
		System.out.println("Repository size with SPOC index only: " + conn.size());
		Model spocStatements = Iterations.addAll(conn.getStatements(null, null, null, false),
				new LinkedHashModel());
		conn.close();
		repo.shutDown();

		// Step 5: check the repository size with PSOC only
		new File(dataDir, "triples.prop").delete(); // delete triples.prop to
																	// update index usage
		repo = new SailRepository(new NativeStore(dataDir, "psoc"));
		repo.initialize();
		conn = repo.getConnection();
		System.out.println("Repository size with PSOC index only: " + conn.size());
		Model psocStatements = Iterations.addAll(conn.getStatements(null, null, null, false),
				new LinkedHashModel());
		conn.close();
		repo.shutDown();

		// Step 6: computing the differences of the contents of the indices
		System.out.println("Computing differences of sets...");

		Collection<? extends Statement> differenceA = RepositoryUtil.difference(spocStatements, psocStatements);
		Collection<? extends Statement> differenceB = RepositoryUtil.difference(psocStatements, spocStatements);

		System.out.println("Difference SPOC MINUS PSOC: " + differenceA.size());
		System.out.println("Difference PSOC MINUS SPOC: " + differenceB.size());

		System.out.println("Different statements in SPOC MINUS PSOC (Mind the contexts):");
		for (Statement st : differenceA) {
			System.out.println("  * " + st);
		}

		System.out.println("Different statements in PSOC MINUS SPOC (Mind the contexts):");
		for (Statement st : differenceB) {
			System.out.println("  * " + st);
		}
		
		assertEquals(0, differenceA.size());
		assertEquals(0, differenceB.size());
	}

}

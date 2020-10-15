/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.citrusframework.yaks.camelk;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import com.consol.citrus.util.FileUtils;
import org.citrusframework.yaks.camelk.model.Integration;
import org.citrusframework.yaks.camelk.model.IntegrationSpec;
import org.junit.Assert;
import org.junit.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StringUtils;

public class IntegrationBuilderTest {

	@Test
	public void buildComplexIntegrationTest() throws IOException {
		Map<String, IntegrationSpec.TraitConfig> traits = new HashMap<>();
		IntegrationSpec.TraitConfig quarkus = new IntegrationSpec.TraitConfig("enabled", "true");
		quarkus.add("native", "true");
		traits.put("quarkus", quarkus);
		traits.put("route", new IntegrationSpec.TraitConfig("enabled", "true"));

		Integration i = new Integration.Builder()
				.name("bar.groovy")
				.source("from(\"timer:x\").log('${body}')")
				.traits(traits)
				.dependencies(Collections.singletonList("mvn:fake.dependency:id:version-1"))
				.build();

		final String json = CamelKSupport.json().writeValueAsString(i);
		Assert.assertEquals(StringUtils.trimAllWhitespace(
				FileUtils.readToString(new ClassPathResource("integration.json", IntegrationBuilderTest.class))), json);
	}
}

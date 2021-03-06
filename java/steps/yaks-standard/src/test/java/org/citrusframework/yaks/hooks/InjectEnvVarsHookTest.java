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

package org.citrusframework.yaks.hooks;

import java.util.Optional;

import com.consol.citrus.DefaultTestCaseRunner;
import com.consol.citrus.TestCaseRunner;
import com.consol.citrus.annotations.CitrusAnnotations;
import com.consol.citrus.context.TestContext;
import com.consol.citrus.context.TestContextFactory;
import org.assertj.core.api.Assertions;
import org.citrusframework.yaks.YaksSettings;
import org.citrusframework.yaks.YaksVariableNames;
import org.junit.Test;

/**
 * @author Christoph Deppisch
 */
public class InjectEnvVarsHookTest {

    @Test
    @SuppressWarnings("CucumberJavaStepDefClassIsPublic")
    public void shouldInjectEnvVars() {
        InjectEnvVarsHook hook = new InjectEnvVarsHook() {
            @Override
            protected Optional<String> getNamespaceSetting() {
                return Optional.of("foo");
            }

            @Override
            protected Optional<String> getClusterWildcardSetting() {
                return Optional.of("foo.cluster.io");
            }
        };

        TestContext context = TestContextFactory.newInstance().getObject();
        TestCaseRunner runner = new DefaultTestCaseRunner(context);
        CitrusAnnotations.injectTestRunner(hook, runner);

        hook.injectEnvVars(null);

        Assertions.assertThat(context.getVariable(YaksVariableNames.NAMESPACE.value())).isEqualTo("foo");
        Assertions.assertThat(context.getVariable(YaksVariableNames.CLUSTER_WILDCARD_DOMAIN.value())).isEqualTo("foo.cluster.io");
    }

    @Test
    @SuppressWarnings("CucumberJavaStepDefClassIsPublic")
    public void shouldInjectEnvVarsDefaultValues() {
        InjectEnvVarsHook hook = new InjectEnvVarsHook() {
            @Override
            protected Optional<String> getNamespaceSetting() {
                return Optional.of("foo");
            }

            @Override
            protected Optional<String> getClusterWildcardSetting() {
                return Optional.empty();
            }
        };

        TestContext context = TestContextFactory.newInstance().getObject();
        TestCaseRunner runner = new DefaultTestCaseRunner(context);
        CitrusAnnotations.injectTestRunner(hook, runner);

        hook.injectEnvVars(null);

        Assertions.assertThat(context.getVariable(YaksVariableNames.NAMESPACE.value())).isEqualTo("foo");
        Assertions.assertThat(context.getVariable(YaksVariableNames.CLUSTER_WILDCARD_DOMAIN.value())).isEqualTo("foo." + YaksSettings.DEFAULT_DOMAIN_SUFFIX);
    }
}

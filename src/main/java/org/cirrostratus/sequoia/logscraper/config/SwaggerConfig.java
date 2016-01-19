/**
 * 
 */
package org.cirrostratus.sequoia.logscraper.config;

import com.mangofactory.swagger.configuration.SpringSwaggerConfig;
import com.mangofactory.swagger.models.dto.ApiInfo;
import com.mangofactory.swagger.plugin.EnableSwagger;
import com.mangofactory.swagger.plugin.SwaggerSpringMvcPlugin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author Will Bartee
 *
 */
@Configuration
@EnableSwagger
@EnableAutoConfiguration
public class SwaggerConfig {

    @Autowired
    private SpringSwaggerConfig springSwaggerConfig;

    @Bean
    public SwaggerSpringMvcPlugin customImplementation() {
        return new SwaggerSpringMvcPlugin(this.springSwaggerConfig)
        // This info will be used in Swagger. See realisation of ApiInfo for more details.
        .apiInfo(apiInfo())
        // Here we disable auto generating of responses for REST-endpoints
        .useDefaultResponseMessages(false)
        /*/ Specify the endpoints that will be used
        .includePatterns(uriPatterns())*/;
    }

    private ApiInfo apiInfo() {
        return new ApiInfo(
                "app name", // Name
                "app description", // Description
                null, // Terms of Serrvice URL
                null, // Contact
                null, // License
                null // License URL
                );
    }
}

GRANT ALL PRIVILEGES ON DATABASE "WSO2AM_DB" TO wso2carbon;
    \c "WSO2AM_DB"
        BEGIN TRANSACTION;
        
        CREATE TABLE IF NOT EXISTS INTERNAL_USER (
        UUID VARCHAR(100) NOT NULL,
        IDP_USER_NAME VARCHAR(255) NOT NULL,
        PRIMARY KEY (UUID),
        UNIQUE (IDP_USER_NAME)
        );
        
        CREATE TABLE IF NOT EXISTS APPLICATION (
        NAME VARCHAR(100),
        USER_UUID VARCHAR(100),
        APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
        CALLBACK_URL VARCHAR(512),
        DESCRIPTION VARCHAR(512),
        APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
        GROUP_ID VARCHAR(100),
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP,
        UUID VARCHAR(256),
        TOKEN_TYPE VARCHAR(10),
        ORGANIZATION VARCHAR(100),
        FOREIGN KEY(USER_UUID) REFERENCES INTERNAL_USER(UUID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY(UUID),
        UNIQUE(NAME,USER_UUID,ORGANIZATION)
        );
        
        CREATE TABLE IF NOT EXISTS API (
        UUID VARCHAR(256),
        API_NAME VARCHAR(256),
        API_VERSION VARCHAR(30),
        CONTEXT VARCHAR(256),
        CONTEXT_TEMPLATE VARCHAR(256),
        API_TIER VARCHAR(256),
        API_TYPE VARCHAR(10),
        ORGANIZATION VARCHAR(100),
        GATEWAY_VENDOR VARCHAR(100) DEFAULT 'wso2',
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP,
        STATUS VARCHAR(30),
        VERSION_COMPARABLE VARCHAR(15),
        LOG_LEVEL VARCHAR(255) DEFAULT 'OFF',
        REVISIONS_CREATED INTEGER DEFAULT 0,
        SDK JSONB,
        CATEGORIES JSONB,
        ARTIFACT JSONB NOT NULL,
        DEFAULT_API_VERSION VARCHAR(30),
        PRIMARY KEY(UUID),
        UNIQUE(API_NAME,API_VERSION,ORGANIZATION)
        );
        
        CREATE TABLE API_ARTIFACT (
        ORGANIZATION VARCHAR(100) NOT NULL,
        API_UUID VARCHAR(256) NOT NULL,
        API_DEFINITION BYTEA,
        MEDIA_TYPE VARCHAR(100),
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON UPDATE CASCADE ON DELETE CASCADE
        );
        
        CREATE SEQUENCE RESOURCE_CATEGORIES_seq;
        CREATE TABLE RESOURCE_CATEGORIES (
        RESOURCE_CATEGORY_ID INTEGER DEFAULT NEXTVAL ('RESOURCE_CATEGORIES_seq'),
        RESOURCE_CATEGORY VARCHAR(255),
        PRIMARY KEY (RESOURCE_CATEGORY_ID),
        UNIQUE (RESOURCE_CATEGORY)
        );
        
        CREATE TABLE API_RESOURCES (
        UUID VARCHAR(255),
        API_UUID VARCHAR(256),
        RESOURCE_CATEGORY_ID INTEGER,
        DATA_TYPE VARCHAR(255),
        RESOURCE_CONTENT TSVECTOR,
        RESOURCE_BINARY_VALUE BYTEA,
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        LAST_UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(UUID),
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON
        UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (RESOURCE_CATEGORY_ID) REFERENCES RESOURCE_CATEGORIES(RESOURCE_CATEGORY_ID)
        );
        
        CREATE TABLE API_DOC_META_DATA(
        UUID VARCHAR(255),
        RESOURCE_UUID VARCHAR(255),
        NAME VARCHAR(255),
        SUMMARY VARCHAR(1024),
        TYPE VARCHAR(255),
        OTHER_TYPE_NAME VARCHAR(255),
        SOURCE_URL VARCHAR(255),
        FILE_NAME VARCHAR(255),
        SOURCE_TYPE VARCHAR(255),
        VISIBILITY VARCHAR(30),
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        LAST_UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(UUID),
        FOREIGN KEY(RESOURCE_UUID) REFERENCES API_RESOURCES(UUID) ON
        UPDATE CASCADE ON DELETE CASCADE
        );
        
        CREATE SEQUENCE API_URL_MAPPING_SEQUENCE START WITH 1 INCREMENT BY 1;
        CREATE TABLE IF NOT EXISTS API_URL_MAPPING (
        URL_MAPPING_ID INTEGER DEFAULT nextval('api_url_mapping_sequence'),
        API_UUID VARCHAR(256) NOT NULL,
        HTTP_METHOD VARCHAR(20) NULL,
        AUTH_SCHEME VARCHAR(50) NULL,
        URL_PATTERN VARCHAR(512) NULL,
        THROTTLING_TIER_UNIT_TIME VARCHAR(255) DEFAULT NULL,
        THROTTLING_TIER_UNIT_VALUE VARCHAR(255) DEFAULT NULL,
        PRIMARY KEY(URL_MAPPING_ID),
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON UPDATE CASCADE ON DELETE CASCADE
        );
        
        CREATE TABLE IF NOT EXISTS API_RESOURCE_SCOPE_MAPPING (
        SCOPE_NAME VARCHAR(256) NOT NULL,
        URL_MAPPING_ID INTEGER NOT NULL,
        FOREIGN KEY(URL_MAPPING_ID) REFERENCES API_URL_MAPPING(URL_MAPPING_ID) ON DELETE CASCADE,
        PRIMARY KEY(SCOPE_NAME, URL_MAPPING_ID)
        );
        
        CREATE TABLE IF NOT EXISTS SUBSCRIPTION (
        UUID VARCHAR(256),
        TIER_ID VARCHAR(50),
        TIER_ID_PENDING VARCHAR(50),
        API_UUID VARCHAR(256),
        LAST_ACCESSED TIMESTAMP NULL,
        APPLICATION_UUID VARCHAR(256),
        SUB_STATUS VARCHAR(50),
        SUBS_CREATE_STATE VARCHAR(50) DEFAULT 'SUBSCRIBE',
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP,
        FOREIGN KEY(APPLICATION_UUID) REFERENCES APPLICATION(UUID) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON
        UPDATE CASCADE ON DELETE CASCADE,
        PRIMARY KEY (UUID)
        );
        
        CREATE TABLE APPLICATION_KEY_MAPPING (
        UUID VARCHAR(100),
        APPLICATION_UUID VARCHAR(256),
        CONSUMER_KEY VARCHAR(512),
        KEY_TYPE VARCHAR(512) NOT NULL,
        CREATE_MODE VARCHAR(30) DEFAULT 'CREATED',
        APP_INFO BYTEA DEFAULT NULL,
        KEY_MANAGER_UUID VARCHAR(100),
        FOREIGN KEY(APPLICATION_UUID) REFERENCES APPLICATION(UUID) ON UPDATE CASCADE ON DELETE CASCADE,
        -- FOREIGN KEY(KEY_MANAGER_UUID) REFERENCES KEY_MANAGER(UUID) ON UPDATE CASCADE ON DELETE CASCADE, --
        PRIMARY KEY(APPLICATION_UUID,KEY_TYPE,KEY_MANAGER_UUID)
        );
        
        CREATE SEQUENCE API_LC_EVENT_SEQUENCE START WITH 1 INCREMENT BY 1;
        CREATE TABLE IF NOT EXISTS API_LC_EVENT (
        EVENT_ID INTEGER DEFAULT nextval('api_lc_event_sequence'),
        API_UUID VARCHAR(256) NOT NULL,
        PREVIOUS_STATE VARCHAR(50),
        NEW_STATE VARCHAR(50) NOT NULL,
        USER_UUID VARCHAR(100) NOT NULL,
        ORGANIZATION VARCHAR(100) NOT NULL,
        EVENT_DATE TIMESTAMP NOT NULL,
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON
        UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(USER_UUID) REFERENCES INTERNAL_USER(UUID) ON UPDATE CASCADE ON DELETE CASCADE,
        PRIMARY KEY (EVENT_ID)
        );
        
        CREATE TABLE IF NOT EXISTS API_COMMENTS (
        COMMENT_ID VARCHAR(64) NOT NULL,
        COMMENT_TEXT VARCHAR(512),
        CREATED_BY VARCHAR(255),
        CREATED_TIME TIMESTAMP NOT NULL,
        UPDATED_TIME TIMESTAMP,
        API_UUID VARCHAR(256),
        PARENT_COMMENT_ID VARCHAR(64) DEFAULT NULL,
        ENTRY_POINT VARCHAR(20),
        CATEGORY VARCHAR(20) DEFAULT 'general',
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON DELETE CASCADE,
        FOREIGN KEY(PARENT_COMMENT_ID) REFERENCES API_COMMENTS(COMMENT_ID),
        PRIMARY KEY(COMMENT_ID)
        );
        
        CREATE TABLE IF NOT EXISTS API_RATINGS (
        RATING_UUID VARCHAR(255) NOT NULL,
        API_UUID VARCHAR(256),
        RATING INTEGER,
        USER_UUID VARCHAR(100),
        FOREIGN KEY(API_UUID) REFERENCES API(UUID) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(USER_UUID) REFERENCES INTERNAL_USER(UUID) ON
        UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY (RATING_UUID)
        );
        
        CREATE TABLE IF NOT EXISTS BUSINESS_PLAN (
        UUID VARCHAR(256),
        NAME VARCHAR(512) NOT NULL,
        DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
        ORGANIZATION VARCHAR(100) NOT NULL,
        DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
        QUOTA_TYPE VARCHAR(25) NOT NULL,
        QUOTA INTEGER NOT NULL,
        QUOTA_UNIT VARCHAR(10) NULL,
        UNIT_TIME INTEGER NOT NULL,
        TIME_UNIT VARCHAR(25) NOT NULL,
        RATE_LIMIT_COUNT INTEGER NULL DEFAULT NULL,
        RATE_LIMIT_TIME_UNIT VARCHAR(25) NULL DEFAULT NULL,
        IS_DEPLOYED BOOLEAN NOT NULL DEFAULT '0',
        CUSTOM_ATTRIBUTES BYTEA DEFAULT NULL,
        STOP_ON_QUOTA_REACH BOOLEAN NOT NULL DEFAULT '0',
        BILLING_PLAN VARCHAR(20) NOT NULL,
        MONETIZATION_PLAN VARCHAR(25) NULL DEFAULT NULL,
        FIXED_RATE VARCHAR(15) NULL DEFAULT NULL,
        BILLING_CYCLE VARCHAR(15) NULL DEFAULT NULL,
        PRICE_PER_REQUEST VARCHAR(15) NULL DEFAULT NULL,
        CURRENCY VARCHAR(15) NULL DEFAULT NULL,
        MAX_COMPLEXITY INTEGER NOT NULL DEFAULT 0,
        MAX_DEPTH INTEGER NOT NULL DEFAULT 0,
        CONNECTIONS_COUNT INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(UUID),
        UNIQUE(NAME, ORGANIZATION)
        );
        
        CREATE TABLE IF NOT EXISTS APPLICATION_USAGE_PLAN (
        NAME VARCHAR(512) NOT NULL,
        DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
        ORGANIZATION VARCHAR(100) NOT NULL,
        DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
        QUOTA_TYPE VARCHAR(25) NOT NULL,
        QUOTA INTEGER NOT NULL,
        QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
        UNIT_TIME INTEGER NOT NULL,
        TIME_UNIT VARCHAR(25) NOT NULL,
        IS_DEPLOYED BOOLEAN NOT NULL DEFAULT '0',
        CUSTOM_ATTRIBUTES BYTEA DEFAULT NULL,
        UUID VARCHAR(256),
        PRIMARY KEY(UUID),
        UNIQUE(NAME, ORGANIZATION)
        );
        
        CREATE TABLE BLOCK_CONDITION (
        TYPE varchar(45) DEFAULT NULL,
        BLOCK_CONDITION varchar(512) DEFAULT NULL,
        ENABLED varchar(45) DEFAULT NULL,
        ORGANIZATION varchar(100) DEFAULT NULL,
        UUID VARCHAR(256),
        PRIMARY KEY (UUID)
        );
        
        CREATE TABLE APPLICATION_GROUP_MAPPING (
        APPLICATION_UUID VARCHAR(256) NOT NULL,
        GROUP_ID VARCHAR(512) NOT NULL,
        ORGANIZATION VARCHAR(100) DEFAULT NULL,
        PRIMARY KEY (APPLICATION_UUID,GROUP_ID,ORGANIZATION),
        FOREIGN KEY (APPLICATION_UUID) REFERENCES APPLICATION(UUID) ON DELETE CASCADE ON UPDATE CASCADE
        );
        
        CREATE TABLE IF NOT EXISTS APPLICATION_ATTRIBUTES (
        APPLICATION_UUID VARCHAR(256) NOT NULL,
        NAME VARCHAR(255) NOT NULL,
        APP_ATTRIBUTE VARCHAR(1024) NOT NULL,
        ORGANIZATION VARCHAR(100) NOT NULL,
        PRIMARY KEY(APPLICATION_UUID,NAME),
        FOREIGN KEY(APPLICATION_UUID) REFERENCES APPLICATION(UUID) ON
        DELETE CASCADE ON UPDATE CASCADE
        );
        
        CREATE TABLE IF NOT EXISTS API_CATEGORIES (
        UUID VARCHAR(50),
        NAME VARCHAR(255),
        DESCRIPTION VARCHAR(1024),
        ORGANIZATION VARCHAR(100),
        UNIQUE(NAME,ORGANIZATION),
        PRIMARY KEY(UUID)
        );

        CREATE TABLE IF NOT EXISTS ORGANIZATION (
        UUID VARCHAR(50),
        NAME VARCHAR(255),
		DISPLAY_NAME VARCHAR(255),
	 	STATUS BOOLEAN NOT NULL DEFAULT 'TRUE',
        NAMESPACE JSONB,
        WORKFLOWS BYTEA,
	 	UNIQUE(NAME),
        PRIMARY KEY(UUID)
        );
		
        CREATE TABLE IF NOT EXISTS ORGANIZATION_CLAIM_MAPPING (
        UUID VARCHAR(50),
        CLAIM_KEY VARCHAR(255),
		CLAIM_VALUE VARCHAR(255),
		FOREIGN KEY(UUID) REFERENCES ORGANIZATION(UUID) ON UPDATE CASCADE ON DELETE CASCADE,
        UNIQUE(UUID,CLAIM_KEY)
        );
		
        CREATE TABLE IF NOT EXISTS ORGANIZATION_VHOST (
        UUID VARCHAR(50),
        VHOST VARCHAR(255),
	    TYPE VARCHAR(50),
        FOREIGN KEY(UUID) REFERENCES ORGANIZATION(UUID) ON UPDATE CASCADE ON DELETE CASCADE,
        UNIQUE(UUID, VHOST, TYPE)
        );
        
        CREATE TABLE IF NOT EXISTS KEY_MANAGER (
        UUID VARCHAR(100) NOT NULL,
        NAME VARCHAR(100) NULL,
        DISPLAY_NAME VARCHAR(100) NULL,
        ISSUER VARCHAR(100) NOT NULL,
        DESCRIPTION VARCHAR(256) NULL,
        TYPE VARCHAR(45) NULL,
        CONFIGURATION BYTEA NULL,
        ENABLED BOOLEAN DEFAULT '1',
        ORGANIZATION VARCHAR(100) NULL,
        PRIMARY KEY(UUID),
        UNIQUE(NAME,ORGANIZATION)
        );
        
        -- End of APK Tables --
        
        -- Performance indexes start--
        
        create index IDX_AI_CTX on API (CONTEXT);
        create index IDX_AI_ORG on API (ORGANIZATION);
        create index IDX_AKM_CK on APPLICATION_KEY_MAPPING (CONSUMER_KEY);
        create index IDX_AUM_AI on API_URL_MAPPING (API_UUID);
        -- create index IDX_AUM_TT on API_URL_MAPPING (THROTTLING_TIER); --
        create index IDX_BP_QT on BUSINESS_PLAN (QUOTA_TYPE);
        create index IDX_S_AITIAI on SUBSCRIPTION (API_UUID,TIER_ID,APPLICATION_UUID);
        create index IDX_AUP_QT on APPLICATION_USAGE_PLAN (QUOTA_TYPE);
        create index IDX_A_AT_CB on APPLICATION (APPLICATION_TIER,CREATED_BY);
        create index IDX_SUB_APP_ID on SUBSCRIPTION (APPLICATION_UUID, UUID);
        
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO wso2carbon;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO wso2carbon;
        GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO wso2carbon;

        -- Insert Initial APK data ---
        INSERT INTO RESOURCE_CATEGORIES (RESOURCE_CATEGORY) VALUES ('Thumbnail');
        -- End Insert Initial APK data        
    
        -- Insert Demo APK data ---
        INSERT INTO INTERNAL_USER(uuid, IDP_USER_NAME) VALUES ( 'apkuser', 'apkuser');
        INSERT INTO organization(uuid, name, display_name, status, workflows) VALUES ( 'a3b58ccf-6ecc-4557-b5bb-0a35cce38256', 'default', 'default', true, '');
        INSERT INTO organization_claim_mapping(uuid, claim_key, claim_value) VALUES ( 'a3b58ccf-6ecc-4557-b5bb-0a35cce38256', 'organizationClaimValue', 'default');
        -- End Insert Demo APK data        
        commit;
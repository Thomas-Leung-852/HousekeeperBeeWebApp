--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY housekeeper_app.storage DROP CONSTRAINT fk_location_id;
ALTER TABLE ONLY housekeeper_app.location DROP CONSTRAINT fk_family_id;
ALTER TABLE ONLY housekeeper_app.member DROP CONSTRAINT fk_family_id;
ALTER TABLE ONLY housekeeper_app.product_barcode DROP CONSTRAINT product_barcode_pkey;
ALTER TABLE ONLY housekeeper_app.mst_storage_status DROP CONSTRAINT pk_storage_status_code;
ALTER TABLE ONLY housekeeper_app.storage DROP CONSTRAINT pk_storage_id;
ALTER TABLE ONLY housekeeper_app.member DROP CONSTRAINT pk_member_id;
ALTER TABLE ONLY housekeeper_app.mst_location_status DROP CONSTRAINT pk_location_status_code;
ALTER TABLE ONLY housekeeper_app.location DROP CONSTRAINT pk_location_id;
ALTER TABLE ONLY housekeeper_app.family DROP CONSTRAINT pk_family_id;
ALTER TABLE ONLY housekeeper_app.mst_avatar_code DROP CONSTRAINT pk_avatar_code;
ALTER TABLE ONLY housekeeper_app.mst_acc_status DROP CONSTRAINT pk_acc_status_code;
ALTER TABLE ONLY housekeeper_app.mst_membership_type DROP CONSTRAINT mst_membership_type_pkey;
ALTER TABLE housekeeper_app.storage ALTER COLUMN location_id DROP DEFAULT;
ALTER TABLE housekeeper_app.storage ALTER COLUMN storage_id DROP DEFAULT;
ALTER TABLE housekeeper_app.member ALTER COLUMN family_id DROP DEFAULT;
ALTER TABLE housekeeper_app.member ALTER COLUMN member_id DROP DEFAULT;
ALTER TABLE housekeeper_app.location ALTER COLUMN family_id DROP DEFAULT;
ALTER TABLE housekeeper_app.location ALTER COLUMN location_id DROP DEFAULT;
ALTER TABLE housekeeper_app.item_audit_trail ALTER COLUMN uid DROP DEFAULT;
ALTER TABLE housekeeper_app.family ALTER COLUMN family_id DROP DEFAULT;
ALTER TABLE housekeeper_app.acc_audit_trail ALTER COLUMN uid DROP DEFAULT;
DROP SEQUENCE housekeeper_app.storage_storage_id_seq;
DROP SEQUENCE housekeeper_app.storage_location_id_seq;
DROP TABLE housekeeper_app.storage;
DROP TABLE housekeeper_app.product_barcode;
DROP TABLE housekeeper_app.mst_storage_status;
DROP TABLE housekeeper_app.mst_membership_type;
DROP TABLE housekeeper_app.mst_location_status;
DROP TABLE housekeeper_app.mst_avatar_code;
DROP TABLE housekeeper_app.mst_acc_status;
DROP SEQUENCE housekeeper_app.member_member_id_seq;
DROP SEQUENCE housekeeper_app.member_family_id_seq;
DROP TABLE housekeeper_app.member;
DROP SEQUENCE housekeeper_app.location_location_id_seq;
DROP SEQUENCE housekeeper_app.location_family_id_seq;
DROP TABLE housekeeper_app.location;
DROP SEQUENCE housekeeper_app.item_audit_trail_uid_seq;
DROP TABLE housekeeper_app.item_audit_trail;
DROP SEQUENCE housekeeper_app.family_family_id_seq;
DROP TABLE housekeeper_app.family;
DROP SEQUENCE housekeeper_app.acc_audit_trail_uid_seq;
DROP TABLE housekeeper_app.acc_audit_trail;
DROP SCHEMA housekeeper_app;
--
-- Name: housekeeper_app; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA housekeeper_app;


ALTER SCHEMA housekeeper_app OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acc_audit_trail; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.acc_audit_trail (
    uid bigint NOT NULL,
    family_code character(32) NOT NULL,
    action_desc character varying(128) NOT NULL,
    action_dt timestamp without time zone NOT NULL,
    member_name character varying(64) NOT NULL
);


ALTER TABLE housekeeper_app.acc_audit_trail OWNER TO postgres;

--
-- Name: acc_audit_trail_uid_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.acc_audit_trail_uid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.acc_audit_trail_uid_seq OWNER TO postgres;

--
-- Name: acc_audit_trail_uid_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.acc_audit_trail_uid_seq OWNED BY housekeeper_app.acc_audit_trail.uid;


--
-- Name: family; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.family (
    family_id integer NOT NULL,
    family_name character varying(32) NOT NULL,
    family_code character varying(32) NOT NULL,
    short_desc character varying(32),
    full_desc character varying(128),
    time_zone_id character varying(32) DEFAULT 'UTC'::character varying,
    owner_name character varying(128),
    owner_login_name character varying(32),
    owner_email_addr character varying(320) NOT NULL,
    verification_code character varying(16),
    verified_email_addr boolean DEFAULT false,
    email_sent_dt timestamp without time zone,
    acc_status_code character(2) DEFAULT 0,
    api_key character varying(256),
    acc_storage_used bigint DEFAULT 0,
    membership_type character varying(16) DEFAULT 'free'::character varying,
    membership_expiry_dt timestamp without time zone,
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.family OWNER TO postgres;

--
-- Name: family_family_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.family_family_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.family_family_id_seq OWNER TO postgres;

--
-- Name: family_family_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.family_family_id_seq OWNED BY housekeeper_app.family.family_id;


--
-- Name: item_audit_trail; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.item_audit_trail (
    uid bigint NOT NULL,
    family_code character(32) NOT NULL,
    location_name character varying(128),
    item_name character varying(128),
    status_before character varying(128),
    status_after character varying(128),
    created_by character varying(64),
    created_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.item_audit_trail OWNER TO postgres;

--
-- Name: item_audit_trail_uid_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.item_audit_trail_uid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.item_audit_trail_uid_seq OWNER TO postgres;

--
-- Name: item_audit_trail_uid_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.item_audit_trail_uid_seq OWNED BY housekeeper_app.item_audit_trail.uid;


--
-- Name: location; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.location (
    location_id integer NOT NULL,
    location_code character(32) NOT NULL,
    location_name character varying(64) NOT NULL,
    short_desc character varying(128),
    img_filename_1 character varying(128),
    img_filename_2 character varying(128),
    img_filename_3 character varying(128),
    location_status_code character(3) DEFAULT 'LS5'::bpchar,
    family_id integer NOT NULL,
    nfc_serial_no character varying(128),
    barcode character varying(24),
    remark character varying(256),
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.location OWNER TO postgres;

--
-- Name: location_family_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.location_family_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.location_family_id_seq OWNER TO postgres;

--
-- Name: location_family_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.location_family_id_seq OWNED BY housekeeper_app.location.family_id;


--
-- Name: location_location_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.location_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.location_location_id_seq OWNER TO postgres;

--
-- Name: location_location_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.location_location_id_seq OWNED BY housekeeper_app.location.location_id;


--
-- Name: member; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.member (
    member_id integer NOT NULL,
    member_code character varying(32) NOT NULL,
    member_name character varying(64) NOT NULL,
    login_name character varying(32) NOT NULL,
    pwd character varying(64) NOT NULL,
    avatar_code character(3) DEFAULT ''::bpchar,
    is_owner boolean DEFAULT false,
    family_id integer NOT NULL,
    ui_lang character varying(8) DEFAULT 'us'::character varying,
    email_send_dt timestamp without time zone,
    ios_udid character varying(64),
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone,
    theme_id integer DEFAULT 1
);


ALTER TABLE housekeeper_app.member OWNER TO postgres;

--
-- Name: member_family_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.member_family_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.member_family_id_seq OWNER TO postgres;

--
-- Name: member_family_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.member_family_id_seq OWNED BY housekeeper_app.member.family_id;


--
-- Name: member_member_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.member_member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.member_member_id_seq OWNER TO postgres;

--
-- Name: member_member_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.member_member_id_seq OWNED BY housekeeper_app.member.member_id;


--
-- Name: mst_acc_status; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.mst_acc_status (
    acc_status_code character(2) NOT NULL,
    acc_status character varying(24) NOT NULL,
    full_desc character varying(128),
    display_ord smallint DEFAULT 1,
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.mst_acc_status OWNER TO postgres;

--
-- Name: TABLE mst_acc_status; Type: COMMENT; Schema: housekeeper_app; Owner: postgres
--

COMMENT ON TABLE housekeeper_app.mst_acc_status IS 'VF = Wait verification
AT = Active
IA = Inactive
LK = Locked
DL = Deleted
';


--
-- Name: mst_avatar_code; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.mst_avatar_code (
    avatar_code character(3) NOT NULL,
    avatar_name character varying(16) NOT NULL,
    img_filename character varying(48) NOT NULL,
    display_ord smallint DEFAULT 1,
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.mst_avatar_code OWNER TO postgres;

--
-- Name: TABLE mst_avatar_code; Type: COMMENT; Schema: housekeeper_app; Owner: postgres
--

COMMENT ON TABLE housekeeper_app.mst_avatar_code IS 'Gender + Age + seq = MA1
Gender (M = Male, F = Female)
Ago (C = child, A = adult, E = elder)
Seq ( 1...9)';


--
-- Name: mst_location_status; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.mst_location_status (
    location_status_code character(3) NOT NULL,
    location_status character varying(48) NOT NULL,
    full_desc character varying(128),
    display_ord smallint DEFAULT 1,
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.mst_location_status OWNER TO postgres;

--
-- Name: TABLE mst_location_status; Type: COMMENT; Schema: housekeeper_app; Owner: postgres
--

COMMENT ON TABLE housekeeper_app.mst_location_status IS 'LS1 = full
LS2 = 75% occupied
LS3 = 50% occupied
LS4 = 25% occupied
LS5 = empty';


--
-- Name: mst_membership_type; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.mst_membership_type (
    membership_type character varying(16) NOT NULL,
    payload character varying(2048),
    support_method character varying(1024),
    sla character varying(1024),
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.mst_membership_type OWNER TO postgres;

--
-- Name: mst_storage_status; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.mst_storage_status (
    storage_status_code character(2) NOT NULL,
    storage_status character varying(48) NOT NULL,
    full_desc character varying(128),
    display_ord smallint DEFAULT 1,
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone
);


ALTER TABLE housekeeper_app.mst_storage_status OWNER TO postgres;

--
-- Name: TABLE mst_storage_status; Type: COMMENT; Schema: housekeeper_app; Owner: postgres
--

COMMENT ON TABLE housekeeper_app.mst_storage_status IS 'OU = check out
N1 = check in, full
N2 = check in, 75% occupied
N3 = check in, 50% occupied
N4 = check in, 25% occupied
N5 = check in, empty';


--
-- Name: product_barcode; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.product_barcode (
    barcode character varying(16) NOT NULL,
    product_title character varying(512),
    product_category character varying(512),
    product_desc character varying(1024),
    record_found boolean DEFAULT false
);


ALTER TABLE housekeeper_app.product_barcode OWNER TO postgres;

--
-- Name: storage; Type: TABLE; Schema: housekeeper_app; Owner: postgres
--

CREATE TABLE housekeeper_app.storage (
    storage_id integer NOT NULL,
    storage_code character varying(32) NOT NULL,
    storage_name character varying(48) NOT NULL,
    short_desc character varying(256),
    storage_status_code character(2) DEFAULT 'OU'::bpchar,
    check_in_dt timestamp without time zone,
    checkout_dt timestamp without time zone,
    remark character varying(256),
    location_id integer NOT NULL,
    img_filename_1 character varying(128),
    img_filename_2 character varying(128),
    img_filename_3 character varying(128),
    nfc_serial_no character varying(128),
    barcode character varying(24),
    created_by character varying(64),
    created_dt timestamp without time zone,
    modified_by character varying(64),
    modified_dt timestamp without time zone,
    ibeacon_uuid character varying(48),
    ibeacon_major integer,
    ibeacon_minor integer,
    ibeacon_identifier character varying(48)
);


ALTER TABLE housekeeper_app.storage OWNER TO postgres;

--
-- Name: storage_location_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.storage_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.storage_location_id_seq OWNER TO postgres;

--
-- Name: storage_location_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.storage_location_id_seq OWNED BY housekeeper_app.storage.location_id;


--
-- Name: storage_storage_id_seq; Type: SEQUENCE; Schema: housekeeper_app; Owner: postgres
--

CREATE SEQUENCE housekeeper_app.storage_storage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE housekeeper_app.storage_storage_id_seq OWNER TO postgres;

--
-- Name: storage_storage_id_seq; Type: SEQUENCE OWNED BY; Schema: housekeeper_app; Owner: postgres
--

ALTER SEQUENCE housekeeper_app.storage_storage_id_seq OWNED BY housekeeper_app.storage.storage_id;


--
-- Name: acc_audit_trail uid; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.acc_audit_trail ALTER COLUMN uid SET DEFAULT nextval('housekeeper_app.acc_audit_trail_uid_seq'::regclass);


--
-- Name: family family_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.family ALTER COLUMN family_id SET DEFAULT nextval('housekeeper_app.family_family_id_seq'::regclass);


--
-- Name: item_audit_trail uid; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.item_audit_trail ALTER COLUMN uid SET DEFAULT nextval('housekeeper_app.item_audit_trail_uid_seq'::regclass);


--
-- Name: location location_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.location ALTER COLUMN location_id SET DEFAULT nextval('housekeeper_app.location_location_id_seq'::regclass);


--
-- Name: location family_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.location ALTER COLUMN family_id SET DEFAULT nextval('housekeeper_app.location_family_id_seq'::regclass);


--
-- Name: member member_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.member ALTER COLUMN member_id SET DEFAULT nextval('housekeeper_app.member_member_id_seq'::regclass);


--
-- Name: member family_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.member ALTER COLUMN family_id SET DEFAULT nextval('housekeeper_app.member_family_id_seq'::regclass);


--
-- Name: storage storage_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.storage ALTER COLUMN storage_id SET DEFAULT nextval('housekeeper_app.storage_storage_id_seq'::regclass);


--
-- Name: storage location_id; Type: DEFAULT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.storage ALTER COLUMN location_id SET DEFAULT nextval('housekeeper_app.storage_location_id_seq'::regclass);


--
-- Data for Name: acc_audit_trail; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.acc_audit_trail (uid, family_code, action_desc, action_dt, member_name) FROM stdin;
\.


--
-- Data for Name: family; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.family (family_id, family_name, family_code, short_desc, full_desc, time_zone_id, owner_name, owner_login_name, owner_email_addr, verification_code, verified_email_addr, email_sent_dt, acc_status_code, api_key, acc_storage_used, membership_type, membership_expiry_dt, created_by, created_dt, modified_by, modified_dt) FROM stdin;
3	My Dream House	35a436d44bb6103226f2d3a71ca24bb0	London	\N	Asia/Hong_Kong	Thomas vNetic	admin	admin@gmail.com	6akk6n4dLu	t	2024-11-15 11:30:38.611	AT	655e60a4a7274a53b5476b47152de9b7	0	FE27	\N	thomas.home.001@gmail.com	2024-11-15 11:30:38.611	\N	2024-11-15 11:31:18.918
\.


--
-- Data for Name: item_audit_trail; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.item_audit_trail (uid, family_code, location_name, item_name, status_before, status_after, created_by, created_dt) FROM stdin;
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.location (location_id, location_code, location_name, short_desc, img_filename_1, img_filename_2, img_filename_3, location_status_code, family_id, nfc_serial_no, barcode, remark, created_by, created_dt, modified_by, modified_dt) FROM stdin;
\.


--
-- Data for Name: member; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.member (member_id, member_code, member_name, login_name, pwd, avatar_code, is_owner, family_id, ui_lang, email_send_dt, ios_udid, created_by, created_dt, modified_by, modified_dt, theme_id) FROM stdin;
3	1cd13666f44b617504981e85bdd96929	User 01	user.01	$2a$10$N3eK3uqOSC/rBc31bIIaXOgEwN.LBUGaJynoZYWt5dE.aitGf5e82	CF1	f	3	us	\N	\N	admin@gmail.com	2024-11-17 02:06:57.554	user.01	2024-12-06 22:57:05.936	1
2	9855e014cf1c2c8e93cce9773e6e7fca	Administrator	admin	$2a$10$N3eK3uqOSC/rBc31bIIaXOgEwN.LBUGaJynoZYWt5dE.aitGf5e82	AM1	t	3	us	\N		admin@gmail.com	2024-11-15 11:31:19.091	admin	2025-03-07 16:22:14.669	3
\.


--
-- Data for Name: mst_acc_status; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.mst_acc_status (acc_status_code, acc_status, full_desc, display_ord, created_by, created_dt, modified_by, modified_dt) FROM stdin;
VF	Verifying	email address verification	1	system	2024-11-15 02:21:04.160644	\N	\N
AT	Active	account in use	2	system	2024-11-15 02:21:04.160644	\N	\N
IA	Inactive	account not in use	3	system	2024-11-15 02:21:04.160644	\N	\N
LK	Locked	account locked	4	system	2024-11-15 02:21:04.160644	\N	\N
DL	Deleted	account deleted	5	system	2024-11-15 02:21:04.160644	\N	\N
\.


--
-- Data for Name: mst_avatar_code; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.mst_avatar_code (avatar_code, avatar_name, img_filename, display_ord, created_by, created_dt, modified_by, modified_dt) FROM stdin;
CM1	Child Male #1	avatar_child_male_1.png	1	system	2024-11-15 02:21:14.295433	\N	\N
CF1	Child Female #1	avatar_child_female_1.png	1	system	2024-11-15 02:21:14.295433	\N	\N
AM1	Audlt Male #1	avatar_adult_male_1.png	1	system	2024-11-15 02:21:14.295433	\N	\N
AF1	Audlt Female #1	avatar_adult_female_1.png	1	system	2024-11-15 02:21:14.295433	\N	\N
EM1	Elder Male #1	avatar_elder_male_1.png	1	system	2024-11-15 02:21:14.295433	\N	\N
EF1	Elder Female #1	avatar_elder_female_1.png	1	system	2024-11-15 02:21:14.295433	\N	\N
\.


--
-- Data for Name: mst_location_status; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.mst_location_status (location_status_code, location_status, full_desc, display_ord, created_by, created_dt, modified_by, modified_dt) FROM stdin;
LS1	Empty		1	system	2024-11-15 02:21:20.882711	\N	\N
LS2	25% occupied		2	system	2024-11-15 02:21:20.882711	\N	\N
LS3	50% occupied		3	system	2024-11-15 02:21:20.882711	\N	\N
LS4	75% occupied		4	system	2024-11-15 02:21:20.882711	\N	\N
LS5	Full		5	system	2024-11-15 02:21:20.882711	\N	\N
\.


--
-- Data for Name: mst_membership_type; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.mst_membership_type (membership_type, payload, support_method, sla, created_by, created_dt, modified_by, modified_dt) FROM stdin;
FE27	WoQy9CP6JSPwpYx4Kodj1LiZ9z+4HTv8P4vpbJOubDAzF0rKn+j5EX8kUV2YbgYhYyY651H9Xx2RdKYvdSm8p8RxA3JEGErwsh7wiomqun6C/3rseY7vywRxWCcuCtxWHMaMQYGsrCkkkE9gmV71fQ==	Website - FAQ	N/A	sys_admin	\N	\N	\N
\.


--
-- Data for Name: mst_storage_status; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.mst_storage_status (storage_status_code, storage_status, full_desc, display_ord, created_by, created_dt, modified_by, modified_dt) FROM stdin;
OU	Check-Out	Storage not at location	1	system	2024-11-15 02:21:27.227018	\N	\N
N1	Check-In, full	Storage at location and fully occupied	6	system	2024-11-15 02:21:27.227018	\N	\N
N2	Check-In, 75% occupied	Storage with 75% occupied at location	5	system	2024-11-15 02:21:27.227018	\N	\N
N3	Check-In, 50% occupied	Storage with 50% occupied at location	4	system	2024-11-15 02:21:27.227018	\N	\N
N4	Check-In, 25% occupied	Storage with 25% occupied at location	3	system	2024-11-15 02:21:27.227018	\N	\N
N5	Check-In empty	Storage at location but empty	2	system	2024-11-15 02:21:27.227018	\N	\N
\.


--
-- Data for Name: product_barcode; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.product_barcode (barcode, product_title, product_category, product_desc, record_found) FROM stdin;
0088381843379	Makita Cp100dz 10.8v Cxt Li-ion Multi Cutter Bare Unit	Hardware > Tools > Cutters > Handheld Metal Shears & Nibblers	The 12-Volt max CXT Multi-Cutter is a cordless cutting solution for cardboard, carpet, leather, rubber, vinyl, and more. With 1/4 In material cutting capacity, 300 RPM, and self-sharpening blade, the Multi-Cutter is engineered for maximum cutting efficiency. Convenience features include a compact and ergonomic design, with a built-on lock-on lever helps prevent the tool from accidentally engaging. 12-Volt max CXT Lithium-Ion batteries are engineered with a Battery Protection Circuit that protects against overloading, over-discharging and over-heating. Its part of the expanding 12-Volt max CXT series, combining performance with superior ergonomics in a compact size	t
9780201379662	Principles of Mechanical Constraint Design (Edition 201) (Paperback)	Media > Books		t
0088381800907	Makita Jr105dz 10.8v Cxt Cordless Reciprocating Saw / Jigsaw Blades 	Hardware > Tools > Saws > Reciprocating Saws		t
6935364080549	Tp-link Mobile Router White Portable	Electronics > Networking > Bridges & Routers > Wireless Routers		t
4894160018465	Unitek Usb 3.0 Mini Dual Bay External Hard Drive Docking Station 2.5 3.5 In 12v	Electronics > Electronics Accessories > Computer Components > Storage Devices > Hard Drive Accessories > Hard Drive Docks	UNITEK USB 3.0 to SATA External Aluminium Hard Drive Docking Station for 2.5"or 3.5"HDD SSD SATA I / II / III, Support UASP & 6TB 8TB	t
8886456550038				f
4895217704874				f
4894514064926				f
5022032145653				f
0064642061379	Jamieson Laboratories Jamieson Glucosamine Sulfate 500 Mg Caplets	Health & Beauty	300+60 caplets	t
4987049318425				f
4711967401217	Ten Ren Green Tea Powder 120g	Food, Beverages & Tobacco > Beverages > Powdered Beverage Mixes		t
4901027613203	OSK New family Sencha (2gX20P) X5 pieces	Food, Beverages & Tobacco > Food Items > Fruits & Vegetables > Fresh & Frozen Vegetables > Greens		t
4897118210164				f
8856976000016	Double A Paper Papier A4 500 v. 80 gr. Paper ? white	Office Supplies > General Office Supplies > Paper Products		t
4573102616081	Mobile Suit Gundam Unicorn Master Grade 1:100 Scale Model Kit		Mobile Suit Gundam Unicorn Master Grade 1:100 Scale Model Kit: Build, pose, and display this Mobile Suit Gundam Unicorn Master Grade 1:100 Scale Model Kit! Ages 15 and up.	t
0192143003007	KODAK Mini 2 Retro 4PASS Portable Photo Printer (2.1x3.4 inches) + 8 Sheets  White	Cameras & Optics > Cameras	Kodak Mini 2 Retro  a portable 2.1x3.4  polaroid photo printer is a great product for printing photographs. The biggest advantage is the price of the film. It is only 30 cents per photo and it is even half the cost if purchased in a bundle. You can connect your Mini 2 Retro to your mobile device such as an iPhone or Android devices  with ease. 4PASS technology is one of the most superior printing technologies available today in terms of print quality. The Kodak APP is a simple and easy way for you to browse  edit  and print all of your photos on the go. There is also a lamination layer  which makes it possible for the photos to be waterproof and fingerprint-proof. Photos will last over a 100 years!	t
0192143001355	Kodak Instant Print 3 X 3 Cartridge - 30 Sheets Brand New			t
9300697114945				f
5016003785504				f
5016003657900				f
0843367123162	Lexar NM620 M.2 2280 1TB PCIe Gen3x4 NVMe 3D TLC Internal Solid State Drive (SSD) LNM620X001T-RNNNG		High-speed PCIe Gen3x4 interface: 3300 MB/s read and 3000 MB/s write - NVMe 1.4 supported M.2 2280 form factor Get 6x the speed of a SATA-based SSD Ideal for PC enthusiasts and gamers 3D NAND Features LDPC (Low-Density Parity Check) Shock and vibration resistant with no moving parts	t
0050036396585				f
1200130002748				f
5056561803302				f
4893899035149				f
4976219124027				f
9318113986519	Minecraft Nsw. Nintendo. Shipping Is Free	Electronics > Video Game Consoles		t
8885011016828				f
4966376184767				f
4977766799492				f
4977766690355				f
0079567850038				f
4897032615120				f
4892018047018				f
9556029510521				f
0890397002790	thinksport Kids Mineral Sunscreen Lotion - SPF 50 - 3 fl oz	Health & Beauty > Personal Care > Cosmetics > Skin Care	THINKsport Aloe After Sun Lotion is a simple, effective gel for sun exposure relief. Like all THINK products, you'll find only safe, natural ingredients that are EWG Verified and our scientific expertise. Aloe Vera After Sun was created to provide a safe solution without harmful chemicals like sulfates, parabens, phthalates, PEGs, and colorants. Apply as needed for soothing relief after sun exposure.	t
8885010233820				f
4516549201021				f
0753759336790				f
4549292041903				f
0037083050028	Titebond  Titebond II Premium Wood Glue  4 oz Net Content  Bottle Container  Liquid Form  Yellow	Hardware > Building Consumables > Hardware Glue & Adhesives	Titebond Wood Adhesive is a premium adhesive formulated specifically for woodworking projects. Renowned for its strong bonding properties  it provides a reliable and durable hold for various types of wood. Its ease of application and quick setting time make it a favorite among both professional woodworkers and DIY enthusiasts.	t
9556108211332	Strepsils Soothing Honey & Lemon 24 Antiseptic Lozenges	Health & Beauty > Health Care > Respiratory Care		t
\.


--
-- Data for Name: storage; Type: TABLE DATA; Schema: housekeeper_app; Owner: postgres
--

COPY housekeeper_app.storage (storage_id, storage_code, storage_name, short_desc, storage_status_code, check_in_dt, checkout_dt, remark, location_id, img_filename_1, img_filename_2, img_filename_3, nfc_serial_no, barcode, created_by, created_dt, modified_by, modified_dt, ibeacon_uuid, ibeacon_major, ibeacon_minor, ibeacon_identifier) FROM stdin;
\.


--
-- Name: acc_audit_trail_uid_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.acc_audit_trail_uid_seq', 1, false);


--
-- Name: family_family_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.family_family_id_seq', 3, true);


--
-- Name: item_audit_trail_uid_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.item_audit_trail_uid_seq', 1, false);


--
-- Name: location_family_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.location_family_id_seq', 1, false);


--
-- Name: location_location_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.location_location_id_seq', 21, true);


--
-- Name: member_family_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.member_family_id_seq', 1, false);


--
-- Name: member_member_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.member_member_id_seq', 3, true);


--
-- Name: storage_location_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.storage_location_id_seq', 1, false);


--
-- Name: storage_storage_id_seq; Type: SEQUENCE SET; Schema: housekeeper_app; Owner: postgres
--

SELECT pg_catalog.setval('housekeeper_app.storage_storage_id_seq', 53, true);


--
-- Name: mst_membership_type mst_membership_type_pkey; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.mst_membership_type
    ADD CONSTRAINT mst_membership_type_pkey PRIMARY KEY (membership_type);


--
-- Name: mst_acc_status pk_acc_status_code; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.mst_acc_status
    ADD CONSTRAINT pk_acc_status_code PRIMARY KEY (acc_status_code);


--
-- Name: mst_avatar_code pk_avatar_code; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.mst_avatar_code
    ADD CONSTRAINT pk_avatar_code PRIMARY KEY (avatar_code);


--
-- Name: family pk_family_id; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.family
    ADD CONSTRAINT pk_family_id PRIMARY KEY (family_id);


--
-- Name: location pk_location_id; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.location
    ADD CONSTRAINT pk_location_id PRIMARY KEY (location_id);


--
-- Name: mst_location_status pk_location_status_code; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.mst_location_status
    ADD CONSTRAINT pk_location_status_code PRIMARY KEY (location_status_code);


--
-- Name: member pk_member_id; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.member
    ADD CONSTRAINT pk_member_id PRIMARY KEY (member_id);


--
-- Name: storage pk_storage_id; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.storage
    ADD CONSTRAINT pk_storage_id PRIMARY KEY (storage_id);


--
-- Name: mst_storage_status pk_storage_status_code; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.mst_storage_status
    ADD CONSTRAINT pk_storage_status_code PRIMARY KEY (storage_status_code);


--
-- Name: product_barcode product_barcode_pkey; Type: CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.product_barcode
    ADD CONSTRAINT product_barcode_pkey PRIMARY KEY (barcode);


--
-- Name: member fk_family_id; Type: FK CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.member
    ADD CONSTRAINT fk_family_id FOREIGN KEY (family_id) REFERENCES housekeeper_app.family(family_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- Name: location fk_family_id; Type: FK CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.location
    ADD CONSTRAINT fk_family_id FOREIGN KEY (family_id) REFERENCES housekeeper_app.family(family_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- Name: storage fk_location_id; Type: FK CONSTRAINT; Schema: housekeeper_app; Owner: postgres
--

ALTER TABLE ONLY housekeeper_app.storage
    ADD CONSTRAINT fk_location_id FOREIGN KEY (location_id) REFERENCES housekeeper_app.location(location_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- PostgreSQL database dump complete
--


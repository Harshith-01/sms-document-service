--
-- PostgreSQL database dump
--

\restrict OTGZFGvrE4U4i7PLwlOBxLdMBqUyNjbxoer5W24LBOQIEb2r64UAR2qkRlnFXd9

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
-- SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_years; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.academic_years (
    id integer NOT NULL,
    year_label character varying(20) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    is_current boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_academic_dates CHECK ((end_date > start_date))
);


ALTER TABLE public.academic_years OWNER TO postgres;

--
-- Name: academic_years_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.academic_years_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.academic_years_id_seq OWNER TO postgres;

--
-- Name: academic_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.academic_years_id_seq OWNED BY public.academic_years.id;


--
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin (
    id character varying(20) NOT NULL,
    user_id character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15),
    designation character varying(100),
    address text
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- Name: attendance_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance_records (
    id integer NOT NULL,
    student_id character varying(20) NOT NULL,
    class_section_id integer NOT NULL,
    attendance_date date NOT NULL,
    status character varying(10) NOT NULL,
    marked_by character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT attendance_records_status_check CHECK (((status)::text = ANY ((ARRAY['PRESENT'::character varying, 'ABSENT'::character varying, 'LATE'::character varying])::text[])))
);


ALTER TABLE public.attendance_records OWNER TO postgres;

--
-- Name: attendance_records_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_records_id_seq OWNER TO postgres;

--
-- Name: attendance_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_records_id_seq OWNED BY public.attendance_records.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    action character varying(50) NOT NULL,
    entity character varying(100) NOT NULL,
    entity_id character varying(50) NOT NULL,
    performed_by character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: class_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_sections (
    id integer NOT NULL,
    class_id integer NOT NULL,
    section_id integer NOT NULL,
    class_teacher_id character varying(20),
    room_number character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    academic_year_id integer,
    capacity integer DEFAULT 40,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    CONSTRAINT chk_section_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'ARCHIVED'::character varying])::text[]))),
    CONSTRAINT class_teacher_not_null_check CHECK (((class_teacher_id IS NULL) OR ((class_teacher_id)::text <> ''::text)))
);


ALTER TABLE public.class_sections OWNER TO postgres;

--
-- Name: class_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_sections_id_seq OWNER TO postgres;

--
-- Name: class_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_sections_id_seq OWNED BY public.class_sections.id;


--
-- Name: class_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_subjects (
    id integer NOT NULL,
    class_id integer NOT NULL,
    subject_id integer NOT NULL,
    is_mandatory boolean DEFAULT true
);


ALTER TABLE public.class_subjects OWNER TO postgres;

--
-- Name: class_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_subjects_id_seq OWNER TO postgres;

--
-- Name: class_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_subjects_id_seq OWNED BY public.class_subjects.id;


--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    class_id integer NOT NULL,
    class_number integer NOT NULL,
    department_id integer,
    academic_year_id integer,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_class_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'ARCHIVED'::character varying])::text[])))
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classes_class_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_class_id_seq OWNER TO postgres;

--
-- Name: classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_class_id_seq OWNED BY public.classes.class_id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_department_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: document_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_requests (
    id integer NOT NULL,
    student_id character varying(20) NOT NULL,
    document_type_id integer NOT NULL,
    purpose text,
    status character varying(50) DEFAULT 'pending'::character varying,
    requested_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    processed_by character varying(20),
    processed_at timestamp without time zone
);


ALTER TABLE public.document_requests OWNER TO postgres;

--
-- Name: document_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_requests_id_seq OWNER TO postgres;

--
-- Name: document_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_requests_id_seq OWNED BY public.document_requests.id;


--
-- Name: document_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.document_types OWNER TO postgres;

--
-- Name: document_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_types_id_seq OWNER TO postgres;

--
-- Name: document_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_types_id_seq OWNED BY public.document_types.id;


--
-- Name: document_verifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_verifications (
    id integer NOT NULL,
    document_id integer NOT NULL,
    verified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    verified_by_ip character varying(50),
    result character varying(50)
);


ALTER TABLE public.document_verifications OWNER TO postgres;

--
-- Name: document_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_verifications_id_seq OWNER TO postgres;

--
-- Name: document_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_verifications_id_seq OWNED BY public.document_verifications.id;


--
-- Name: elective_group_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elective_group_subjects (
    id integer NOT NULL,
    group_id integer,
    subject_id integer
);


ALTER TABLE public.elective_group_subjects OWNER TO postgres;

--
-- Name: elective_group_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.elective_group_subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.elective_group_subjects_id_seq OWNER TO postgres;

--
-- Name: elective_group_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.elective_group_subjects_id_seq OWNED BY public.elective_group_subjects.id;


--
-- Name: elective_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elective_groups (
    id integer NOT NULL,
    class_id integer NOT NULL,
    group_name character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.elective_groups OWNER TO postgres;

--
-- Name: elective_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.elective_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.elective_groups_id_seq OWNER TO postgres;

--
-- Name: elective_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.elective_groups_id_seq OWNED BY public.elective_groups.id;


--
-- Name: parents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parents (
    id character varying(20) NOT NULL,
    father_name character varying(100),
    mother_name character varying(100),
    primary_contact character varying(15),
    secondary_contact character varying(15),
    email character varying(100),
    address text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    guardian_name character varying(150),
    guardian_contact character varying(15),
    guardian_email character varying(150),
    permanent_address text,
    occupation character varying(150),
    annual_income character varying(50),
    updated_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.parents OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    role_name character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sections (
    section_id integer NOT NULL,
    section_name character varying(10) NOT NULL
);


ALTER TABLE public.sections OWNER TO postgres;

--
-- Name: sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sections_section_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sections_section_id_seq OWNER TO postgres;

--
-- Name: sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sections_section_id_seq OWNED BY public.sections.section_id;


--
-- Name: student_academic_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_academic_info (
    id integer NOT NULL,
    student_id character varying(20) NOT NULL,
    program_name character varying(150),
    department character varying(150),
    semester_year character varying(50),
    enrollment_date date,
    previous_college character varying(150),
    previous_marks character varying(50),
    academic_status character varying(50),
    updated_at timestamp with time zone DEFAULT now(),
    is_current boolean DEFAULT true,
    class_section_id integer,
    CONSTRAINT chk_academic_status CHECK ((((academic_status)::text = ANY ((ARRAY['Active'::character varying, 'Graduated'::character varying, 'Dropped'::character varying, 'Transferred'::character varying])::text[])) OR (academic_status IS NULL)))
);


ALTER TABLE public.student_academic_info OWNER TO postgres;

--
-- Name: student_academic_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_academic_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_academic_info_id_seq OWNER TO postgres;

--
-- Name: student_academic_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_academic_info_id_seq OWNED BY public.student_academic_info.id;


--
-- Name: student_admissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_admissions (
    id integer NOT NULL,
    student_id character varying(20) NOT NULL,
    admission_number character varying(50) NOT NULL,
    admission_date date DEFAULT CURRENT_DATE,
    admission_type character varying(50),
    admission_category character varying(50),
    entrance_exam_name character varying(100),
    entrance_exam_rank integer,
    fees_payment_status character varying(50),
    scholarship_details character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    entrance_exam character varying(150),
    rank character varying(50),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_fees_status CHECK ((((fees_payment_status)::text = ANY ((ARRAY['Paid'::character varying, 'Pending'::character varying, 'Partial'::character varying])::text[])) OR (fees_payment_status IS NULL)))
);


ALTER TABLE public.student_admissions OWNER TO postgres;

--
-- Name: student_admissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_admissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_admissions_id_seq OWNER TO postgres;

--
-- Name: student_admissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_admissions_id_seq OWNED BY public.student_admissions.id;


--
-- Name: student_contact_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_contact_info (
    id integer NOT NULL,
    student_id character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    contact_number character varying(15) NOT NULL,
    alternate_number character varying(15),
    current_address text,
    permanent_address text,
    city character varying(100),
    state character varying(100),
    pin_code character varying(10),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.student_contact_info OWNER TO postgres;

--
-- Name: student_contact_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_contact_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_contact_info_id_seq OWNER TO postgres;

--
-- Name: student_contact_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_contact_info_id_seq OWNED BY public.student_contact_info.id;


--
-- Name: student_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_documents (
    id integer NOT NULL,
    student_id character varying(20) NOT NULL,
    admission_id integer,
    document_type_id integer NOT NULL,
    file_url text NOT NULL,
    issued_by character varying(20),
    issued_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50) DEFAULT 'issued'::character varying,
    verification_code character varying(100)
);


ALTER TABLE public.student_documents OWNER TO postgres;

--
-- Name: student_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_documents_id_seq OWNER TO postgres;

--
-- Name: student_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_documents_id_seq OWNED BY public.student_documents.id;


--
-- Name: student_subject_enrollments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_subject_enrollments (
    id integer NOT NULL,
    student_id character varying NOT NULL,
    subject_id integer NOT NULL,
    academic_year_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    class_section_id integer NOT NULL
);


ALTER TABLE public.student_subject_enrollments OWNER TO postgres;

--
-- Name: student_subject_enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_subject_enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_subject_enrollments_id_seq OWNER TO postgres;

--
-- Name: student_subject_enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_subject_enrollments_id_seq OWNED BY public.student_subject_enrollments.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id character varying(20) NOT NULL,
    user_id character varying(20) NOT NULL,
    parent_id character varying(20),
    full_name character varying(150) NOT NULL,
    date_of_birth date,
    gender character varying(10),
    blood_group character varying(5),
    created_at timestamp with time zone DEFAULT now(),
    admission_number character varying(50),
    nationality character varying(50),
    aadhaar_number character varying(20),
    photo_url text,
    is_active boolean DEFAULT true NOT NULL,
    deleted_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now(),
    created_by character varying(20),
    updated_by character varying(20),
    CONSTRAINT chk_aadhaar_format CHECK ((((aadhaar_number)::text ~ '^[0-9]{12}$'::text) OR (aadhaar_number IS NULL))),
    CONSTRAINT chk_blood_group CHECK ((((blood_group)::text = ANY ((ARRAY['A+'::character varying, 'A-'::character varying, 'B+'::character varying, 'B-'::character varying, 'AB+'::character varying, 'AB-'::character varying, 'O+'::character varying, 'O-'::character varying])::text[])) OR (blood_group IS NULL))),
    CONSTRAINT chk_gender CHECK ((((gender)::text = ANY ((ARRAY['Male'::character varying, 'Female'::character varying, 'Other'::character varying])::text[])) OR (gender IS NULL)))
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    subject_name character varying(100) NOT NULL,
    subject_code character varying(20) NOT NULL,
    department_id integer,
    is_elective boolean DEFAULT false,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_subject_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subjects_id_seq OWNER TO postgres;

--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- Name: teacher_academic_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_academic_details (
    teacher_id character varying(20) NOT NULL,
    academic_year character varying(20) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL,
    CONSTRAINT academic_year_format_check CHECK (((academic_year)::text ~ '^[0-9]{4}-[0-9]{2}$'::text))
);


ALTER TABLE public.teacher_academic_details OWNER TO postgres;

--
-- Name: teacher_academic_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_academic_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teacher_academic_details_id_seq OWNER TO postgres;

--
-- Name: teacher_academic_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teacher_academic_details_id_seq OWNED BY public.teacher_academic_details.id;


--
-- Name: teacher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teacher_id_seq OWNER TO postgres;

--
-- Name: teacher_qualifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_qualifications (
    teacher_id character varying(20) NOT NULL,
    academic_qualifications text,
    specialization text,
    experience text,
    publications text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL
);


ALTER TABLE public.teacher_qualifications OWNER TO postgres;

--
-- Name: teacher_qualifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_qualifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teacher_qualifications_id_seq OWNER TO postgres;

--
-- Name: teacher_qualifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teacher_qualifications_id_seq OWNED BY public.teacher_qualifications.id;


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teachers (
    id character varying(20) NOT NULL,
    user_id character varying(20) NOT NULL,
    full_name character varying(150) NOT NULL,
    email_id character varying(255) NOT NULL,
    contact_number character varying(15),
    communication_address text,
    designation character varying(100),
    employment_type character varying(50),
    date_of_joining date,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    department_id integer,
    CONSTRAINT teacher_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'TRANSFERRED'::character varying, 'RESIGNED'::character varying, 'RETIRED'::character varying])::text[])))
);


ALTER TABLE public.teachers OWNER TO postgres;

--
-- Name: teaching_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teaching_assignments (
    id integer NOT NULL,
    teacher_id character varying NOT NULL,
    class_section_id integer NOT NULL,
    subject_id integer NOT NULL,
    academic_year_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.teaching_assignments OWNER TO postgres;

--
-- Name: teaching_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teaching_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teaching_assignments_id_seq OWNER TO postgres;

--
-- Name: teaching_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teaching_assignments_id_seq OWNED BY public.teaching_assignments.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_id_seq
    START WITH 6
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_id_seq OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id character varying(20) NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: academic_years id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_years ALTER COLUMN id SET DEFAULT nextval('public.academic_years_id_seq'::regclass);


--
-- Name: attendance_records id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records ALTER COLUMN id SET DEFAULT nextval('public.attendance_records_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: class_sections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections ALTER COLUMN id SET DEFAULT nextval('public.class_sections_id_seq'::regclass);


--
-- Name: class_subjects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_subjects ALTER COLUMN id SET DEFAULT nextval('public.class_subjects_id_seq'::regclass);


--
-- Name: classes class_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN class_id SET DEFAULT nextval('public.classes_class_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: document_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requests ALTER COLUMN id SET DEFAULT nextval('public.document_requests_id_seq'::regclass);


--
-- Name: document_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types ALTER COLUMN id SET DEFAULT nextval('public.document_types_id_seq'::regclass);


--
-- Name: document_verifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_verifications ALTER COLUMN id SET DEFAULT nextval('public.document_verifications_id_seq'::regclass);


--
-- Name: elective_group_subjects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_group_subjects ALTER COLUMN id SET DEFAULT nextval('public.elective_group_subjects_id_seq'::regclass);


--
-- Name: elective_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_groups ALTER COLUMN id SET DEFAULT nextval('public.elective_groups_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: sections section_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sections ALTER COLUMN section_id SET DEFAULT nextval('public.sections_section_id_seq'::regclass);


--
-- Name: student_academic_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_academic_info ALTER COLUMN id SET DEFAULT nextval('public.student_academic_info_id_seq'::regclass);


--
-- Name: student_admissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_admissions ALTER COLUMN id SET DEFAULT nextval('public.student_admissions_id_seq'::regclass);


--
-- Name: student_contact_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_contact_info ALTER COLUMN id SET DEFAULT nextval('public.student_contact_info_id_seq'::regclass);


--
-- Name: student_documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents ALTER COLUMN id SET DEFAULT nextval('public.student_documents_id_seq'::regclass);


--
-- Name: student_subject_enrollments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments ALTER COLUMN id SET DEFAULT nextval('public.student_subject_enrollments_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- Name: teacher_academic_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_academic_details ALTER COLUMN id SET DEFAULT nextval('public.teacher_academic_details_id_seq'::regclass);


--
-- Name: teacher_qualifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_qualifications ALTER COLUMN id SET DEFAULT nextval('public.teacher_qualifications_id_seq'::regclass);


--
-- Name: teaching_assignments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments ALTER COLUMN id SET DEFAULT nextval('public.teaching_assignments_id_seq'::regclass);


--
-- Name: academic_years academic_years_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_years
    ADD CONSTRAINT academic_years_pkey PRIMARY KEY (id);


--
-- Name: academic_years academic_years_year_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_years
    ADD CONSTRAINT academic_years_year_label_key UNIQUE (year_label);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id);


--
-- Name: admin admin_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_user_id_key UNIQUE (user_id);


--
-- Name: attendance_records attendance_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: class_sections class_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections
    ADD CONSTRAINT class_sections_pkey PRIMARY KEY (id);


--
-- Name: class_subjects class_subjects_class_id_subject_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_subjects
    ADD CONSTRAINT class_subjects_class_id_subject_id_key UNIQUE (class_id, subject_id);


--
-- Name: class_subjects class_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_subjects
    ADD CONSTRAINT class_subjects_pkey PRIMARY KEY (id);


--
-- Name: classes classes_class_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_class_number_key UNIQUE (class_number);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (class_id);


--
-- Name: departments departments_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_key UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: document_requests document_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requests
    ADD CONSTRAINT document_requests_pkey PRIMARY KEY (id);


--
-- Name: document_types document_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_name_key UNIQUE (name);


--
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- Name: document_verifications document_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_verifications
    ADD CONSTRAINT document_verifications_pkey PRIMARY KEY (id);


--
-- Name: elective_group_subjects elective_group_subjects_group_id_subject_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_group_subjects
    ADD CONSTRAINT elective_group_subjects_group_id_subject_id_key UNIQUE (group_id, subject_id);


--
-- Name: elective_group_subjects elective_group_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_group_subjects
    ADD CONSTRAINT elective_group_subjects_pkey PRIMARY KEY (id);


--
-- Name: elective_groups elective_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_groups
    ADD CONSTRAINT elective_groups_pkey PRIMARY KEY (id);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (section_id);


--
-- Name: sections sections_section_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_section_name_key UNIQUE (section_name);


--
-- Name: student_academic_info student_academic_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_academic_info
    ADD CONSTRAINT student_academic_info_pkey PRIMARY KEY (id);


--
-- Name: student_admissions student_admissions_admission_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_admissions
    ADD CONSTRAINT student_admissions_admission_number_key UNIQUE (admission_number);


--
-- Name: student_admissions student_admissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_admissions
    ADD CONSTRAINT student_admissions_pkey PRIMARY KEY (id);


--
-- Name: student_admissions student_admissions_student_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_admissions
    ADD CONSTRAINT student_admissions_student_id_key UNIQUE (student_id);


--
-- Name: student_contact_info student_contact_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_contact_info
    ADD CONSTRAINT student_contact_info_pkey PRIMARY KEY (id);


--
-- Name: student_contact_info student_contact_info_student_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_contact_info
    ADD CONSTRAINT student_contact_info_student_id_key UNIQUE (student_id);


--
-- Name: student_documents student_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents
    ADD CONSTRAINT student_documents_pkey PRIMARY KEY (id);


--
-- Name: student_documents student_documents_verification_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents
    ADD CONSTRAINT student_documents_verification_code_key UNIQUE (verification_code);


--
-- Name: student_subject_enrollments student_subject_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments
    ADD CONSTRAINT student_subject_enrollments_pkey PRIMARY KEY (id);


--
-- Name: student_subject_enrollments student_subject_enrollments_student_id_subject_id_academic__key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments
    ADD CONSTRAINT student_subject_enrollments_student_id_subject_id_academic__key UNIQUE (student_id, subject_id, academic_year_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: students students_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_key UNIQUE (user_id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_subject_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_subject_code_key UNIQUE (subject_code);


--
-- Name: teacher_academic_details teacher_academic_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_academic_details
    ADD CONSTRAINT teacher_academic_details_pkey PRIMARY KEY (id);


--
-- Name: teacher_qualifications teacher_qualifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_qualifications
    ADD CONSTRAINT teacher_qualifications_pkey PRIMARY KEY (id);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--
-- Name: teachers teachers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_key UNIQUE (user_id);


--
-- Name: teaching_assignments teaching_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments
    ADD CONSTRAINT teaching_assignments_pkey PRIMARY KEY (id);


--
-- Name: teaching_assignments teaching_assignments_teacher_id_class_section_id_subject_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments
    ADD CONSTRAINT teaching_assignments_teacher_id_class_section_id_subject_id_key UNIQUE (teacher_id, class_section_id, subject_id, academic_year_id);


--
-- Name: students unique_active_admission; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT unique_active_admission UNIQUE (admission_number);


--
-- Name: attendance_records unique_attendance_per_day; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT unique_attendance_per_day UNIQUE (student_id, attendance_date);


--
-- Name: class_sections unique_class_section_year; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections
    ADD CONSTRAINT unique_class_section_year UNIQUE (class_id, section_id, academic_year_id);


--
-- Name: teacher_academic_details unique_teacher_academic_year; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_academic_details
    ADD CONSTRAINT unique_teacher_academic_year UNIQUE (teacher_id, academic_year);


--
-- Name: teachers unique_teacher_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT unique_teacher_email UNIQUE (email_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_academic_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_academic_student_id ON public.student_academic_info USING btree (student_id);


--
-- Name: idx_academic_year_current; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_academic_year_current ON public.academic_years USING btree (is_current);


--
-- Name: idx_admission_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admission_student_id ON public.student_admissions USING btree (student_id);


--
-- Name: idx_audit_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_entity ON public.audit_logs USING btree (entity);


--
-- Name: idx_audit_performed_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_performed_by ON public.audit_logs USING btree (performed_by);


--
-- Name: idx_class_section_capacity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_class_section_capacity ON public.class_sections USING btree (capacity);


--
-- Name: idx_class_subject_class; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_class_subject_class ON public.class_subjects USING btree (class_id);


--
-- Name: idx_class_subject_subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_class_subject_subject ON public.class_subjects USING btree (subject_id);


--
-- Name: idx_class_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_class_teacher_id ON public.class_sections USING btree (class_teacher_id);


--
-- Name: idx_classes_academic_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_academic_year ON public.classes USING btree (academic_year_id);


--
-- Name: idx_classes_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_department ON public.classes USING btree (department_id);


--
-- Name: idx_contact_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contact_student_id ON public.student_contact_info USING btree (student_id);


--
-- Name: idx_documents_admission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_admission_id ON public.student_documents USING btree (admission_id);


--
-- Name: idx_documents_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_student_id ON public.student_documents USING btree (student_id);


--
-- Name: idx_section_academic_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_section_academic_year ON public.class_sections USING btree (academic_year_id);


--
-- Name: idx_student_academic_current; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_academic_current ON public.student_academic_info USING btree (class_section_id, is_current);


--
-- Name: idx_student_subject_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_subject_section ON public.student_subject_enrollments USING btree (class_section_id);


--
-- Name: idx_student_subject_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_subject_student ON public.student_subject_enrollments USING btree (student_id);


--
-- Name: idx_student_subject_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_subject_year ON public.student_subject_enrollments USING btree (academic_year_id);


--
-- Name: idx_students_aadhaar_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_students_aadhaar_unique ON public.students USING btree (aadhaar_number) WHERE (aadhaar_number IS NOT NULL);


--
-- Name: idx_students_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_students_active ON public.students USING btree (id) WHERE (is_active = true);


--
-- Name: idx_students_admission_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_students_admission_unique ON public.students USING btree (admission_number) WHERE (is_active = true);


--
-- Name: idx_subject_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subject_department ON public.subjects USING btree (department_id);


--
-- Name: idx_teacher_academic_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teacher_academic_teacher ON public.teacher_academic_details USING btree (teacher_id);


--
-- Name: idx_teacher_designation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teacher_designation ON public.teachers USING btree (designation);


--
-- Name: idx_teacher_doj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teacher_doj ON public.teachers USING btree (date_of_joining);


--
-- Name: idx_teacher_qualification_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teacher_qualification_teacher ON public.teacher_qualifications USING btree (teacher_id);


--
-- Name: idx_teacher_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teacher_status ON public.teachers USING btree (status);


--
-- Name: idx_teaching_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teaching_section ON public.teaching_assignments USING btree (class_section_id);


--
-- Name: idx_teaching_subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teaching_subject ON public.teaching_assignments USING btree (subject_id);


--
-- Name: idx_teaching_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teaching_teacher ON public.teaching_assignments USING btree (teacher_id);


--
-- Name: unique_current_academic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_current_academic ON public.student_academic_info USING btree (student_id) WHERE (is_current = true);


--
-- Name: unique_current_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_current_year ON public.academic_years USING btree (is_current) WHERE (is_current = true);


--
-- Name: departments update_department_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_department_updated_at BEFORE UPDATE ON public.departments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subjects update_subject_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_subject_updated_at BEFORE UPDATE ON public.subjects FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: teacher_academic_details update_teacher_academic_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_teacher_academic_updated_at BEFORE UPDATE ON public.teacher_academic_details FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: teacher_qualifications update_teacher_qualification_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_teacher_qualification_updated_at BEFORE UPDATE ON public.teacher_qualifications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: teachers update_teacher_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_teacher_updated_at BEFORE UPDATE ON public.teachers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: class_sections class_sections_academic_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections
    ADD CONSTRAINT class_sections_academic_year_id_fkey FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: class_subjects class_subjects_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_subjects
    ADD CONSTRAINT class_subjects_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(class_id) ON DELETE CASCADE;


--
-- Name: class_subjects class_subjects_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_subjects
    ADD CONSTRAINT class_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: classes classes_academic_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_academic_year_id_fkey FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: classes classes_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: elective_group_subjects elective_group_subjects_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_group_subjects
    ADD CONSTRAINT elective_group_subjects_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.elective_groups(id) ON DELETE CASCADE;


--
-- Name: elective_group_subjects elective_group_subjects_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_group_subjects
    ADD CONSTRAINT elective_group_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: elective_groups elective_groups_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_groups
    ADD CONSTRAINT elective_groups_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(class_id) ON DELETE CASCADE;


--
-- Name: student_academic_info fk_academic_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_academic_info
    ADD CONSTRAINT fk_academic_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: admin fk_admin_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_admissions fk_admission_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_admissions
    ADD CONSTRAINT fk_admission_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: attendance_records fk_att_marker; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT fk_att_marker FOREIGN KEY (marked_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: attendance_records fk_att_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT fk_att_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: class_sections fk_class; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections
    ADD CONSTRAINT fk_class FOREIGN KEY (class_id) REFERENCES public.classes(class_id) ON DELETE CASCADE;


--
-- Name: class_sections fk_class_teacher; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections
    ADD CONSTRAINT fk_class_teacher FOREIGN KEY (class_teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: student_contact_info fk_contact_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_contact_info
    ADD CONSTRAINT fk_contact_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: student_documents fk_doc_admission; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents
    ADD CONSTRAINT fk_doc_admission FOREIGN KEY (admission_id) REFERENCES public.student_admissions(id) ON DELETE SET NULL;


--
-- Name: student_documents fk_doc_issuer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents
    ADD CONSTRAINT fk_doc_issuer FOREIGN KEY (issued_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: student_documents fk_doc_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents
    ADD CONSTRAINT fk_doc_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: student_documents fk_doc_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_documents
    ADD CONSTRAINT fk_doc_type FOREIGN KEY (document_type_id) REFERENCES public.document_types(id) ON DELETE CASCADE;


--
-- Name: document_requests fk_docreq_admin; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requests
    ADD CONSTRAINT fk_docreq_admin FOREIGN KEY (processed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: document_requests fk_docreq_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requests
    ADD CONSTRAINT fk_docreq_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: document_requests fk_docreq_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requests
    ADD CONSTRAINT fk_docreq_type FOREIGN KEY (document_type_id) REFERENCES public.document_types(id) ON DELETE CASCADE;


--
-- Name: user_roles fk_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: class_sections fk_section; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_sections
    ADD CONSTRAINT fk_section FOREIGN KEY (section_id) REFERENCES public.sections(section_id) ON DELETE CASCADE;


--
-- Name: student_academic_info fk_student_class_section; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_academic_info
    ADD CONSTRAINT fk_student_class_section FOREIGN KEY (class_section_id) REFERENCES public.class_sections(id) ON DELETE SET NULL;


--
-- Name: students fk_student_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fk_student_parent FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON DELETE SET NULL;


--
-- Name: students fk_student_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: teacher_academic_details fk_teacher_academic; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_academic_details
    ADD CONSTRAINT fk_teacher_academic FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: teachers fk_teacher_department; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT fk_teacher_department FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: teacher_qualifications fk_teacher_qualification; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_qualifications
    ADD CONSTRAINT fk_teacher_qualification FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: teachers fk_teacher_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT fk_teacher_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_roles fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: document_verifications fk_verify_doc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_verifications
    ADD CONSTRAINT fk_verify_doc FOREIGN KEY (document_id) REFERENCES public.student_documents(id) ON DELETE CASCADE;


--
-- Name: student_subject_enrollments student_subject_enrollments_academic_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments
    ADD CONSTRAINT student_subject_enrollments_academic_year_id_fkey FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: student_subject_enrollments student_subject_enrollments_class_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments
    ADD CONSTRAINT student_subject_enrollments_class_section_id_fkey FOREIGN KEY (class_section_id) REFERENCES public.class_sections(id) ON DELETE CASCADE;


--
-- Name: student_subject_enrollments student_subject_enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments
    ADD CONSTRAINT student_subject_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: student_subject_enrollments student_subject_enrollments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subject_enrollments
    ADD CONSTRAINT student_subject_enrollments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: subjects subjects_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: teaching_assignments teaching_assignments_academic_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments
    ADD CONSTRAINT teaching_assignments_academic_year_id_fkey FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: teaching_assignments teaching_assignments_class_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments
    ADD CONSTRAINT teaching_assignments_class_section_id_fkey FOREIGN KEY (class_section_id) REFERENCES public.class_sections(id) ON DELETE CASCADE;


--
-- Name: teaching_assignments teaching_assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments
    ADD CONSTRAINT teaching_assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: teaching_assignments teaching_assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_assignments
    ADD CONSTRAINT teaching_assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict OTGZFGvrE4U4i7PLwlOBxLdMBqUyNjbxoer5W24LBOQIEb2r64UAR2qkRlnFXd9



-- fee_schema_upgrades.sql
-- Scaffolds new tables for the fees-service in a PostgreSQL database

CREATE TABLE public.student_fee_terms (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    academic_year_id INTEGER,
    term_name VARCHAR(50) NOT NULL, -- e.g., 'Mid Term', 'Final Term'
    total_amount NUMERIC(10, 2) NOT NULL,
    amount_paid NUMERIC(10, 2) DEFAULT 0.00,
    balance_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'UNPAID', -- UNPAID, PARTIAL, COMPLETED
    due_date DATE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_status CHECK (status IN ('UNPAID', 'PARTIAL', 'COMPLETED'))
);

CREATE TABLE public.fee_payments (
    id SERIAL PRIMARY KEY,
    term_id INTEGER REFERENCES public.student_fee_terms(id) ON DELETE CASCADE,
    payment_amount NUMERIC(10, 2) NOT NULL,
    payment_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50), -- e.g., 'CASH', 'BANK_TRANSFER', 'CARD'
    reference_id VARCHAR(100),
    remarks TEXT
);

-- ============================================================
-- Document Service Specific Tables
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;

CREATE TABLE public.documents (
    id UUID PRIMARY KEY DEFAULT public.uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL, -- 'student', 'teacher', 'staff', 'parent'
    
    -- Explicit Foreign Keys ensuring relational integrity
    student_id VARCHAR(20) REFERENCES public.students(id) ON DELETE CASCADE,
    teacher_id VARCHAR(20) REFERENCES public.teachers(id) ON DELETE CASCADE,
    staff_id VARCHAR(20) REFERENCES public.non_teaching_staff(id) ON DELETE CASCADE,
    parent_id VARCHAR(20) REFERENCES public.parents(id) ON DELETE CASCADE,
    
    document_type VARCHAR(100) NOT NULL,
    is_profile_photo BOOLEAN NOT NULL DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    file_url TEXT NOT NULL,
    cloudinary_public_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending_verification', -- 'pending_verification', 'verified', 'rejected'
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by VARCHAR(50),
    rejection_reason TEXT,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT chk_document_entity CHECK (
        (entity_type = 'student' AND student_id IS NOT NULL AND teacher_id IS NULL AND staff_id IS NULL AND parent_id IS NULL) OR
        (entity_type = 'teacher' AND teacher_id IS NOT NULL AND student_id IS NULL AND staff_id IS NULL AND parent_id IS NULL) OR
        (entity_type = 'staff' AND staff_id IS NOT NULL AND student_id IS NULL AND teacher_id IS NULL AND parent_id IS NULL) OR
        (entity_type = 'parent' AND parent_id IS NOT NULL AND student_id IS NULL AND teacher_id IS NULL AND staff_id IS NULL)
    )
);

CREATE INDEX idx_documents_student ON public.documents (student_id) WHERE student_id IS NOT NULL;
CREATE INDEX idx_documents_teacher ON public.documents (teacher_id) WHERE teacher_id IS NOT NULL;
CREATE INDEX idx_documents_staff ON public.documents (staff_id) WHERE staff_id IS NOT NULL;
CREATE INDEX idx_documents_parent ON public.documents (parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX idx_documents_type ON public.documents (document_type);

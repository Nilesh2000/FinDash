--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: mutual_funds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mutual_funds (
    id integer NOT NULL,
    scheme_code integer NOT NULL,
    scheme_name text NOT NULL,
    fund_house text NOT NULL,
    scheme_category text NOT NULL,
    scheme_type text NOT NULL,
    asset_class text NOT NULL,
    fund_type text NOT NULL,
    risk_level text NOT NULL,
    benchmark text NOT NULL,
    plan_type text NOT NULL,
    option_type text NOT NULL,
    expense_ratio numeric(5,2) NOT NULL,
    inception_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT mutual_funds_asset_class_check CHECK ((asset_class = ANY (ARRAY['Equity'::text, 'Debt'::text, 'Hybrid'::text, 'Gold'::text]))),
    CONSTRAINT mutual_funds_expense_ratio_check CHECK (((expense_ratio >= (0)::numeric) AND (expense_ratio <= (100)::numeric))),
    CONSTRAINT mutual_funds_fund_type_check CHECK ((fund_type = ANY (ARRAY['Active'::text, 'Passive'::text]))),
    CONSTRAINT mutual_funds_option_type_check CHECK ((option_type = ANY (ARRAY['Growth'::text, 'IDCW'::text]))),
    CONSTRAINT mutual_funds_plan_type_check CHECK ((plan_type = ANY (ARRAY['Direct'::text, 'Regular'::text]))),
    CONSTRAINT mutual_funds_risk_level_check CHECK ((risk_level = ANY (ARRAY['Low'::text, 'Moderate'::text, 'Moderately High'::text, 'High'::text, 'Very High'::text]))),
    CONSTRAINT mutual_funds_scheme_type_check CHECK ((scheme_type = ANY (ARRAY['Open Ended'::text, 'Close Ended'::text, 'ELSS'::text])))
);


--
-- Name: mutual_funds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mutual_funds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mutual_funds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mutual_funds_id_seq OWNED BY public.mutual_funds.id;


--
-- Name: nav_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nav_history (
    id integer NOT NULL,
    mf_id integer,
    date date NOT NULL,
    nav numeric(10,4) NOT NULL,
    CONSTRAINT nav_history_nav_check CHECK ((nav >= (0)::numeric))
);


--
-- Name: nav_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nav_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nav_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nav_history_id_seq OWNED BY public.nav_history.id;


--
-- Name: sips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sips (
    id integer NOT NULL,
    mf_id integer,
    amount numeric(18,2) NOT NULL,
    frequency text NOT NULL,
    debit_day integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    status text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT sips_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT sips_check CHECK (((end_date IS NULL) OR (end_date > start_date))),
    CONSTRAINT sips_debit_day_check CHECK (((debit_day >= 1) AND (debit_day <= 31))),
    CONSTRAINT sips_frequency_check CHECK ((frequency = ANY (ARRAY['Monthly'::text, 'Quarterly'::text, 'Yearly'::text]))),
    CONSTRAINT sips_status_check CHECK ((status = ANY (ARRAY['Active'::text, 'Paused'::text, 'Completed'::text, 'Cancelled'::text])))
);


--
-- Name: sips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sips_id_seq OWNED BY public.sips.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    mf_id integer,
    txn_type text NOT NULL,
    txn_date date NOT NULL,
    units numeric(18,4) NOT NULL,
    nav numeric(10,4) NOT NULL,
    txn_amount numeric(18,2) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT transactions_nav_check CHECK ((nav >= (0)::numeric)),
    CONSTRAINT transactions_txn_amount_check CHECK ((txn_amount >= (0)::numeric)),
    CONSTRAINT transactions_txn_date_check CHECK ((txn_date <= CURRENT_DATE)),
    CONSTRAINT transactions_txn_type_check CHECK ((txn_type = ANY (ARRAY['Lumpsum'::text, 'SIP Purchase'::text, 'Redemption'::text]))),
    CONSTRAINT transactions_units_check CHECK ((units >= (0)::numeric))
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: mutual_funds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mutual_funds ALTER COLUMN id SET DEFAULT nextval('public.mutual_funds_id_seq'::regclass);


--
-- Name: nav_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nav_history ALTER COLUMN id SET DEFAULT nextval('public.nav_history_id_seq'::regclass);


--
-- Name: sips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sips ALTER COLUMN id SET DEFAULT nextval('public.sips_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: mutual_funds mutual_funds_fund_house_scheme_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mutual_funds
    ADD CONSTRAINT mutual_funds_fund_house_scheme_name_key UNIQUE (fund_house, scheme_name);


--
-- Name: mutual_funds mutual_funds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mutual_funds
    ADD CONSTRAINT mutual_funds_pkey PRIMARY KEY (id);


--
-- Name: mutual_funds mutual_funds_scheme_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mutual_funds
    ADD CONSTRAINT mutual_funds_scheme_code_key UNIQUE (scheme_code);


--
-- Name: nav_history nav_history_mf_id_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nav_history
    ADD CONSTRAINT nav_history_mf_id_date_key UNIQUE (mf_id, date);


--
-- Name: nav_history nav_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nav_history
    ADD CONSTRAINT nav_history_pkey PRIMARY KEY (id);


--
-- Name: sips sips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sips
    ADD CONSTRAINT sips_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: mutual_funds trigger_update_mutual_funds; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_mutual_funds BEFORE UPDATE ON public.mutual_funds FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: sips trigger_update_sip; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_sip BEFORE UPDATE ON public.sips FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: nav_history nav_history_mf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nav_history
    ADD CONSTRAINT nav_history_mf_id_fkey FOREIGN KEY (mf_id) REFERENCES public.mutual_funds(id) ON DELETE CASCADE;


--
-- Name: sips sips_mf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sips
    ADD CONSTRAINT sips_mf_id_fkey FOREIGN KEY (mf_id) REFERENCES public.mutual_funds(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_mf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_mf_id_fkey FOREIGN KEY (mf_id) REFERENCES public.mutual_funds(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


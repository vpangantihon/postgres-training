
--database: banking_system

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS accounts CASCADE;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	balance NUMERIC NOT NULL DEFAULT 0.0,
	maintaining_balance NUMERIC NOT NULL DEFAULT 500.0,
	customer_id INT NOT NULL,
	CONSTRAINT fk_customer_id
	  FOREIGN KEY (customer_id)
	  REFERENCES customers(id)
);

DROP TABLE IF EXISTS account_transactions CASCADE;
CREATE TABLE IF NOT EXISTS account_transactions (
	id SERIAL PRIMARY KEY,
	amount NUMERIC NOT NULL,
	transaction_type VARCHAR(1),
	account_id INT NOT NULL,
	CONSTRAINT fk_account_id
	  FOREIGN KEY (account_id)
	  REFERENCES accounts(id),
	beginning_balance DECIMAL NOT NULL,
	ending_balance DECIMAL NOT NULL
);


ALTER TABLE account_transactions
  ADD CONSTRAINT check_transaction_type
  CHECK (transaction_type IN ('W','D'));


INSERT INTO customers (first_name, last_name) VALUES ('Raphael','Alampay');
INSERT INTO accounts (customer_id) VALUES(1);

SELECT * FROM accounts;

DROP FUNCTION IF EXISTS get_total_balance;
CREATE OR REPLACE FUNCTION get_total_balance(
	customer_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  total_balance NUMERIC := 0.0;
BEGIN
  SELECT SUM(balance) INTO total_balance FROM accounts WHERE customer_id = customer_id;

  RETURN total_balance;
END;$$;

-- Create a function deposit(id, amount) return BOOLEAN
DROP FUNCTION IF EXISTS  deposit;
CREATE OR REPLACE FUNCTION deposit(
  _id INT,
  _amount NUMERIC
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  result BOOLEAN := TRUE;
  current_balance NUMERIC;
  new_balance NUMERIC;
BEGIN
  SELECT balance INTO current_balance FROM accounts where accounts.id = _id;

  new_balance := current_balance + _amount;

  UPDATE accounts SET balance = new_balance WHERE accounts.id = _id;

  RETURN result;
END;$$;

SELECT deposit (1, 1000.0);
SELECT * FROM accounts;


DROP FUNCTION IF EXISTS withdraw;
CREATE OR REPLACE FUNCTION withdraw (
  _id INT,
  _amount NUMERIC
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  result BOOLEAN := TRUE;
  current_balance NUMERIC;
  new_balance NUMERIC;
  _maintaining_balance NUMERIC;
BEGIN
  SELECT balance, maintaining_balance INTO current_balance,_maintaining_balance FROM accounts WHERE accounts.id = _id;

  new_balance := current_balance - _amount;

  IF new_balance < _maintaining_balance THEN
    result := FALSE;
    RAISE NOTICE 'Account % will have below % maintaining balance for the withdrawal amount of % from %', _id, _maintaining_balance, _amount, current_balance;
  ELSE
    UPDATE accounts SET balance = new_balance WHERE accounts.id = _id;
  END IF;

  RETURN result;
END;$$;

DROP PROCEDURE IF EXISTS p_withdraw;
CREATE OR REPLACE PROCEDURE p_withdraw(
  _id INT,
  _amount NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
  current_balance NUMERIC;
  new_balance NUMERIC;
  result BOOLEAN;
BEGIN
  SELECT balance INTO current_balance FROM accounts WHERE accounts.id = _id;
  SELECT withdraw(_id, _amount) INTO result;

  IF result THEN
    SELECT balance INTO new_balance FROM accounts WHERE accounts.id = _id;

    INSERT INTO account_transactions(account_id, amount, transaction_type, beginning_balance, ending_balance)
	VALUES (_id, _amount, 'W', current_balance, new_balance);
  END IF;
END;$$;


-- withdraw
CALL p_withdraw(1, 100.0);
SELECT * FROM accounts;
SELECT * FROM account_transactions;


DROP PROCEDURE IF EXISTS p_deposit;
CREATE OR REPLACE PROCEDURE p_deposit(
  _id INT,
  _amount NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
  current_balance NUMERIC;
  new_balance NUMERIC;
  result BOOLEAN;
BEGIN
  SELECT balance INTO current_balance FROM accounts WHERE accounts.id = _id;
  SELECT deposit(_id, _amount) INTO result;

  IF result THEN
    SELECT balance INTO new_balance FROM accounts WHERE accounts.id = _id;

    INSERT INTO account_transactions(account_id, amount, transaction_type, beginning_balance, ending_balance) VALUES (_id, _amount, 'D', current_balance, new_balance);
  END IF;
END;$$;


-- deposit
CALL p_deposit(1, 500.0);
SELECT * FROM accounts;
SELECT * FROM account_transactions;

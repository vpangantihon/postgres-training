DROP TABLE IF EXISTS products;

CREATE TABLE IF NOT EXISTS products (
	id INT,
	name VARCHAR(50),
	description TEXT
);


CREATE SEQUENCE products_id_seq
	AS INTEGER START 1 OWNED BY products.id;

ALTER TABLE products
	ALTER COLUMN id SET DEFAULT nextval('products_id_seq');

ALTER TABLE products
	ADD CONSTRAINT pk_products
	PRIMARY KEY (id);


DROP TABLE IF EXISTS branches;

CREATE TABLE IF NOT EXISTS branches (
	id INT,
	name VARCHAR(50)
);

CREATE SEQUENCE branches_id_seq
	AS INTEGER START 1 OWNED BY branches.id;

ALTER TABLE branches
	ALTER COLUMN id SET DEFAULT nextval('branches_id_seq');

ALTER TABLE branches
	ADD CONSTRAINT pk_branches
	PRIMARY KEY (id);



DROP TABLE IF EXISTS categories;


CREATE TABLE IF NOT EXISTS categories (
	id INT,
	name VARCHAR(50)
);


CREATE SEQUENCE categories_id_seq
	AS INTEGER START 1 OWNED BY categories.id;

ALTER TABLE categories
	ALTER COLUMN id SET DEFAULT nextval('categories_id_seq');

ALTER TABLE categories
	ADD CONSTRAINT pk_categories
	PRIMARY KEY (id);


ALTER TABLE products
	ADD COLUMN category_id INT NOT NULL;

ALTER TABLE products
	ADD CONSTRAINT fk_category_id
	FOREIGN KEY (category_id)
	REFERENCES categories(id);


ALTER TABLE products
	ADD COLUMN branch_id INT NOT NULL;

ALTER TABLE products
	ADD CONSTRAINT fk_branch_id
	FOREIGN KEY (branch_id)
	REFERENCES branches(id);

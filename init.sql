-- we don't know how to generate root <with-no-name> (class Root) :(
create table category
(
	id INTEGER
		constraint category_pk
			primary key autoincrement,
	name TEXT not null,
	packages INTEGER default 0 not null
);

create unique index category_name_uindex
	on category (name);

create table tag
(
	id INTEGER
		constraint tag_pk
			primary key autoincrement,
	name TEXT not null,
	packages INTEGER default 0
);

create unique index tag_name_uindex
	on tag (name);

create table token
(
	id INTEGER
		constraint token_pk
			primary key,
	user_id INTEGER not null,
	ip TEXT not null,
	value TEXT not null
);

create table user
(
	id INTEGER
		constraint user_pk
			primary key autoincrement,
	github_id INTEGER not null,
	name TEXT,
	username TEXT not null,
	avatar_url TEXT,
	is_blocked BOOLEAN default 0,
	is_admin BOOLEAN default 0
);

create table package
(
	id INTEGER
		constraint package_pk
			primary key autoincrement,
	author_id INTEGER not null
		references user,
	name TEXT not null,
	description TEXT default '',
	license TEXT,
	vcs TEXT default 'git',
	repo_url TEXT not null,
	stars INTEGER default 0,
	downloads INTEGER default 0,
	downloaded_at TIMESTAMP,
	updated_at TIMESTAMP default CURRENT_TIMESTAMP,
	created_at TIMESTAMP default CURRENT_TIMESTAMP
);

create unique index package_name_uindex
	on package (name);

create unique index package_repo_url_uindex
	on package (repo_url);

CREATE TRIGGER update_package_downloaded_at_after_update
			AFTER UPDATE ON package
		BEGIN
			UPDATE package
			SET downloaded_at = CURRENT_TIMESTAMP
			WHERE id = new.id AND old.downloads != new.downloads;
		END;

CREATE TRIGGER update_updated_at_after_update
			AFTER UPDATE ON package
		BEGIN
			UPDATE package
			SET updated_at = CURRENT_TIMESTAMP
			WHERE id = new.id;
		END;

create table package_to_category
(
	package_id INTEGER not null
		references package,
	category_id INTEGER not null
		references category
);

CREATE TRIGGER update_category_packages_after_delete
			AFTER DELETE ON package_to_category
		BEGIN
			UPDATE category
			SET packages = packages - 1
			WHERE id = old.category_id;
		END;

CREATE TRIGGER update_category_packages_after_insert
			AFTER INSERT ON package_to_category
		BEGIN
			UPDATE category
			SET packages = packages + 1
			WHERE id = new.category_id;
		END;

create table package_to_tag
(
	package_id INTEGER not null
		references package,
	tag_id INTEGER not null
		references tag
);

CREATE TRIGGER update_tag_packages_after_delete
			AFTER DELETE ON package_to_tag
		BEGIN
			UPDATE tag
			SET packages = packages - 1
			WHERE id = old.tag_id;
		END;

CREATE TRIGGER update_tag_packages_after_insert
			AFTER INSERT ON package_to_tag
		BEGIN
			UPDATE tag
			SET packages = packages + 1
			WHERE id = new.tag_id;
		END;

create unique index user_username_uindex
	on user (username);

create table version
(
	id INTEGER
		constraint version_pk
			primary key autoincrement,
	package_id INTEGER not null
		references package,
	name TEXT not null,
	commit_hash TEXT not null,
	date TIMESTAMP default CURRENT_TIMESTAMP,
	release_url TEXT not null,
	downloads INTEGER default 0
);

create table dependency
(
	version_id INTEGER not null,
	dependency_id INTEGER not null,
	foreign key (version_id, dependency_id) references version (id, id)
);

create unique index version_commit_hash_uindex
	on version (commit_hash);

create unique index version_name_uindex
	on version (name);

CREATE TRIGGER update_package_downloads_after_update
			AFTER UPDATE ON version
		BEGIN
			UPDATE package
			SET downloads = downloads + (new.downloads - old.downloads)
			WHERE id = new.package_id;
		END;

CREATE VIEW most_downloadable_packages as
	select * from package order by downloads desc;

CREATE VIEW most_recent_downloads as
	select * from package order by downloaded_at desc;

CREATE VIEW new_packages as
	select * from package order by created_at desc;

CREATE VIEW popular_categories as
	select * from category order by packages desc;

CREATE VIEW popular_tags as
	select * from tag order by packages desc;

CREATE VIEW recently_updated_packages as
	select * from package order by updated_at;


-- region Prod and Dev
ALTER USER MAPPING FOR pardi_admin
SERVER irdb OPTIONS (SET PASSWORD :password);
-- endregion

-- region (Dev)-only
ALTER USER MAPPING FOR jenkins
SERVER irdb OPTIONS (SET PASSWORD :password);
-- endregion
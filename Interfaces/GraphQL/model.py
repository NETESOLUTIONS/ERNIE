import re
from os import environ

import inflect
from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import scoped_session, sessionmaker

# region Selected tables only
# from sqlalchemy import MetaData
# endregion

_inflector = inflect.engine()


def standardize_class_name(base, tablename, table):
    """
    Produce a class name in PascalCase and singular, e.g. 'my_entities' -> 'MyEntity'

    :param base:
    :param tablename:
    :param table:
    :return:
    """

    return _inflector.singular_noun(tablename[0].upper() +
                                    re.sub(r'_([a-z])', lambda m: m.group(1).upper(), tablename[1:]))


def standardize_collection_name(base, local_cls, referred_cls, constraint):
    """
    Produce a collection name in snake_case and plural, e.g. "'SomeTerm' -> 'some_terms'"

    :param base:
    :param local_cls:
    :param referred_cls:
    :param constraint:
    :return:
    """

    return _inflector.plural(re.sub(r'[A-Z]',
                                    lambda m: "_%s" % m.group(0).lower(),
                                    referred_cls.__name__)[1:])


if environ.get('PGUSER') and environ.get('PGPASSWORD') and environ.get('PGHOST') and environ.get('PGPORT') and \
        environ.get('PGDATABASE'):
    engine = create_engine('postgresql+psycopg2://{}:{}@{}:{}/{}'.format(
        environ.get('PGUSER'), environ.get('PGPASSWORD'), environ.get('PGHOST'), environ.get('PGPORT'),
        environ.get('PGDATABASE')), echo=True)
else:
    engine = create_engine('postgresql+psycopg2://@/{}'.format(environ.get('PGDATABASE')), echo=True)

print("Getting metadata for the public schema...")

# region Selected tables only
metadata = MetaData()
# We can reflect metadata from a database, using options such as 'only' to limit what tables we look at
metadata.reflect(engine, schema="public", only=['ct_clinical_studies', 'ct_keywords', 'exporter_projects'])
# We can then produce a set of mappings from this MetaData
Base = automap_base(metadata=metadata)
# Calling prepare() just sets up mapped classes and relationships
Base.prepare(classname_for_table=standardize_class_name, name_for_collection_relationship=standardize_collection_name)
# endregion

# region The entire schema
# Base = automap_base()
# Base.prepare(engine, reflect=True, schema="public", classname_for_table=standardize_class_name,
#              name_for_collection_relationship=standardize_collection_name)
# endregion

print("Metadata is retrieved...")

# mapped classes are now created with names by default matching that of the table name.
# DerwentPatent = Base.classes.derwent_patents
# WosPublication = Base.classes.wos_publications

# db_session = Session(engine)
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
Base.query = db_session.query_property()

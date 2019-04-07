#!/usr/bin/env python

from flask import Flask
from flask_graphql import GraphQLView

from graphql_schema import schema
from model import db_session

app = Flask(__name__)
app.debug = True

app.add_url_rule('/', view_func=GraphQLView.as_view('graphql', schema=schema, graphiql=True))


@app.teardown_appcontext
def shutdown_session(exception=None):
    db_session.remove()


if __name__ == '__main__':
    app.run()

from graphene import ObjectType, Schema
from graphene import relay
from graphene_sqlalchemy import SQLAlchemyObjectType

from InstrumentedQuery import InstrumentedQuery
from model import Base


class ClinicalTrial(SQLAlchemyObjectType):
    class Meta:
        model = Base.classes.CtClinicalStudy
        interfaces = (relay.Node,)


class ClinicalTrialKeyword(SQLAlchemyObjectType):
    class Meta:
        model = Base.classes.CtKeyword
        interfaces = (relay.Node,)


class NIHProject(SQLAlchemyObjectType):
    class Meta:
        model = Base.classes.ExporterProject
        interfaces = (relay.Node,)

# class UsPatent(SQLAlchemyObjectType):
#     class Meta:
#         model = Base.classes.DerwentPatent
#         interfaces = (relay.Node,)


class Query(ObjectType):
    node = relay.Node.Field()
    # usPatents = InstrumentedQuery(UsPatent)
    clinicalTrials = InstrumentedQuery(ClinicalTrial)
    clinicalTrialKeywords = InstrumentedQuery(ClinicalTrialKeyword)
    nihProjects = InstrumentedQuery(NIHProject)


schema = Schema(query=Query, types=[ClinicalTrial, ClinicalTrialKeyword])

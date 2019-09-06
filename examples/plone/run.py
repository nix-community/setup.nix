from zope.component.hooks import setSite
from Products.CMFPlone.factory import addPloneSite
import transaction

ADMIN_USER = 'admin'
ADMIN_PASSWD = 'admin'

app.acl_users._doAddUser(ADMIN_USER, ADMIN_PASSWD, ['Manager'], [])

if 'Plone' not in app.objectIds():
    site_id = 'Plone'
    addPloneSite(app, site_id)
    plone = getattr(app, site_id)
    setSite(plone)

    stool = plone.portal_setup
    for profile in [
        'profile-plone.app.contenttypes:default',
        'profile-plonetheme.barceloneta:default',
        'profile-plone.restapi:default',
    ]:
        try:
            stool.runAllImportStepsFromProfile(
                profile, dependency_strategy='reapply')
        except:
            stool.runAllImportStepsFromProfile(profile)

transaction.commit()

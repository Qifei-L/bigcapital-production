import os
os.chdir('/home/frappe/frappe-bench/sites')
import frappe.app
from frappe.runner import main
# A single-site deployment also answers Railway healthchecks with an internal Host.
frappe.app._site = os.environ["SITE_NAME"]
main()

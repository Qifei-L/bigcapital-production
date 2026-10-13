import os
import frappe
from frappe_books.frappe_books.doctype.books_setup_wizard.books_setup_wizard import complete_setup
frappe.init(site=os.environ["SITE_NAME"], sites_path="sites")
frappe.connect()
frappe.set_user("Administrator")
try:
    if not frappe.db.get_single_value("Books Accounting Settings", "setup_complete"):
        wizard = frappe.get_single("Books Setup Wizard")
        wizard.update({
            "company_name": "Demo Company", "fullname": "Demo Administrator",
            "email": "demo@example.com", "country": "United States", "currency": "USD",
            "bank_name": "Demo Bank", "chart_of_accounts": "Standard Chart of Accounts",
            "fiscal_year_start": "2026-01-01", "fiscal_year_end": "2026-12-31",
            "time_zone": "America/New_York"
        })
        wizard.save(ignore_permissions=True)
        complete_setup()
    frappe.db.set_single_value("Website Settings", "disable_signup", 1)
    frappe.db.commit()
    print("BOOKS_DEMO_READY", flush=True)
finally:
    frappe.destroy()

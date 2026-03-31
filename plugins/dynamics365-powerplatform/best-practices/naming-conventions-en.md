# Naming conventions guide - Dynamics 365 & Power Platform

## 📋 Table of Contents

1. [Data Model (Tables & Columns)](#1-data-model-tables--columns)
2. [User Interface (Forms, Views & Visualizations)](#2-user-interface-forms-views--visualizations)
3. [Business Logic (Declarative)](#3-business-logic-declarative)
4. [Server-Side Code (C# / Plugins)](#4-server-side-code-c--plugins)
5. [Custom APIs & Actions](#5-custom-apis--actions)
6. [Client-Side Code (JavaScript / Web Resources)](#6-client-side-code-javascript--web-resources)
7. [Automation (Power Automate)](#7-automation-power-automate)
8. [Power Platform Apps](#8-power-platform-apps)
9. [Queries & Data Retrieval](#9-queries--data-retrieval)
10. [Solution & Configuration](#10-solution--configuration)
11. [Naming Style Conventions](#naming-style-conventions)

---

## 1. DATA MODEL (Tables & Columns)

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Table (Entity)** | Represents a set of data such as 'Account' or 'Contact' | Account, Contact, new_CustomEntity | | new_ (for custom) | PascalCase | Publisher prefix is automatically added to custom tables |
| **Column (Attribute)** | Fields within a table | firstname, new_customfield | | new_ (for custom) | lowercase | System fields use lowercase, custom fields get publisher prefix |
| **Lookup Column** | Reference to another table | primarycontactid, new_projectmanagerid | id | new_ (for custom) | lowercase | Always ends with "id" |
| **Calculated Column** | Column whose value is automatically calculated | totalamount, new_fulladdress | | new_ (for custom) | lowercase | Cannot be used in rollups |
| **Rollup Column** | Aggregates values from related records | totalopportunityvalue | | new_ (for custom) | lowercase | Calculated periodically, not real-time |
| **DateTime Column** | Stores date and time values | createdon, modifiedon, new_startdate | on (system), date (custom) | new_ (for custom) | lowercase | Use "on" for timestamps, "date" for dates |
| **Money Column** | Stores currency values | revenue, new_budget | | new_ (for custom) | lowercase | Automatically includes base currency field |
| **Image Column** | Stores one image per record | entityimage, new_profilepicture | | new_ (for custom) | lowercase | Limited to one per table (entityimage) |
| **File Column** | Stores attached files | new_contractdocument, new_attachment | | new_ (for custom) | lowercase | Supports multiple files per record |
| **Choice (Option Set)** | Local dropdown values for a column | statuscode, new_projectstatus | | new_ (for custom) | lowercase | Previously called "Option Set" |
| **Global Choice** | Reusable choice values across multiple columns | Industry, Payment Terms | | new_ (for custom) | PascalCase | Renamed from "Global Option Set" to "Choice" |
| **Relationship** | Defines how two tables are connected | account_contact, new_account_new_project | | new_ (for custom) | snake_case | Created automatically when adding Lookup field |
| **Alternate Key** | Additional unique identifier for a table | accountnumber, new_externalid | | new_ (for custom) | lowercase | Useful for integrations |

---

## 2. USER INTERFACE (Forms, Views & Visualizations)

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Form** | User interface to view and edit records | Account Main Form, Information | | | PascalCase with spaces | Avoid generic names like "Main Form" |
| **View** | Set of columns and filters to display records | Active Contacts, My Open Opportunities | | | PascalCase with spaces | Use descriptive names indicating filter criteria |
| **Chart** | Data visualization based on views | Top 10 Customers, Sales by Region | | | PascalCase with spaces | |
| **Dashboard** | Group of charts and views for visual analysis | Sales Performance Dashboard, Service Manager Dashboard | Dashboard | | PascalCase with spaces | Include context of what it displays |

---

## 3. BUSINESS LOGIC (Declarative)

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Business Rule** | Declarative logic applied to forms | Set Priority Based on Customer Type | Rule | | PascalCase with spaces | Describe what the rule does |
| **Business Process Flow** | Step-by-step guide for completing processes | Lead to Opportunity Sales Process | | | PascalCase with spaces | Include "Process" for clarity |
| **Workflow (Classic)** | Declarative process automation | Lead Qualification WF | WF | | PascalCase with spaces | **Deprecated** - Use Power Automate instead |

---

## 4. SERVER-SIDE CODE (C# / Plugins)

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Plugin Class** | Custom logic triggered by events | AccountCreatePlugin, PreValidateContact | Plugin | | PascalCase | Include stage (Pre/Post) and message for clarity |
| **Plugin Step** | Registration of plugin execution | PreCreate of account, PostUpdate of contact | | | Descriptive | Register with specific message and stage |
| **Class (C#)** | Encapsulated logic or model | InvoiceProcessor, EmailService | | | PascalCase | No need for "Class" suffix |
| **Interface (C#)** | Contract for classes | IEmailSender, IRepository | | I | PascalCase | Always prefix with "I" |
| **Enum (C#)** | Set of named constants | StatusCode, InvoiceType | | | PascalCase | No need for "Enum" suffix |
| **Public Method (C#)** | Exposed method in plugin or class | ExecuteWorkflow, ValidateAddress | | | PascalCase | |
| **Private Method (C#)** | Internal method in plugin or class | checkPermissions, formatPhoneNumber | | | camelCase | |
| **Variable (C# local)** | Local variable in code | customerName, isValid | | | camelCase | Use descriptive names |

---

## 5. CUSTOM APIS & ACTIONS

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Custom API** | Custom endpoint for integration | new_CalculateTax | API | new_ (for custom) | PascalCase | **Preferred over Custom Actions** |
| **Custom Action** | Reusable logic exposed as a service | new_SendEmailNotification | Action | new_ (for custom) | PascalCase | Consider Custom API instead |

---

## 6. CLIENT-SIDE CODE (JavaScript / Web Resources)

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Web Resource (JavaScript)** | Client-side script file | new_/scripts/accountForm.js | .js | new_/ | camelCase for functions | Use folder structure in name |
| **Web Resource (CSS)** | Styling resource | new_/styles/customTheme.css | .css | new_/ | kebab-case | |
| **Web Resource (HTML)** | HTML page resource | new_/pages/customReport.html | .html | new_/ | kebab-case | |
| **JavaScript Function** | Client-side logic on forms | validateEmail, onLoadForm, onSaveRecord | | | camelCase | Prefix event handlers with "on" |
| **JavaScript Variable (local)** | Local variable in code | customerName, isValid | | | camelCase | Use descriptive names |
| **PCF Control** | Custom UI component | RatingControl, MapComponent | Control | | PascalCase | PowerApps Component Framework |

---

## 7. AUTOMATION (Power Automate)

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Power Automate Flow (Cloud)** | Cloud-based automation with connectors | Create Invoice on Order Approval | | | PascalCase with spaces | Describe trigger and action |
| **Power Automate Desktop Flow** | RPA automation | Extract Data from Legacy System | | | PascalCase with spaces | For UI automation and legacy systems |

---

## 8. POWER PLATFORM APPS

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Model-Driven App** | Dynamics-based structured app | Sales Hub, Customer Service | | | PascalCase with spaces | Match intended user role |
| **Canvas App** | Custom app built with Power Apps | Field Service Mobile App, Expense Tracker | App | | PascalCase with spaces | Describe purpose |
| **Power Pages (Portal)** | External-facing website | Customer Self-Service Portal, Partner Portal | Portal | | PascalCase with spaces | Formerly Power Apps Portals |

---

## 9. QUERIES & DATA RETRIEVAL

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Query Expression** | LINQ or QueryExpression query | accountQuery, activeContactsQuery | Query | | camelCase | |
| **FetchXML** | XML-based query | fetchActiveAccounts | fetch | | camelCase | Prefix with "fetch" |

---

## 10. SOLUTION & CONFIGURATION

| Metadata Type | Description | Usage Example | Recommended Suffix | Recommended Prefix | Naming Style | Note |
|--------------|-------------|---------------|-------------------|-------------------|--------------|------|
| **Solution** | Container for customizations and components | ContosoSales, BSHParamountFS | | Publisher prefix | PascalCase | Use meaningful name reflecting functionality |
| **Environment Variable** | Configuration value across environments | BaseAPIUrl, MaxRetryCount | | | PascalCase | Use instead of hardcoded values |
| **Connection Reference** | Reusable connector in solutions | SharePoint Connection, SQL Server Connection | | | PascalCase with spaces | Makes flows solution-aware |
| **Security Role** | Controls access to data and features | Sales Manager, Customer Service Rep | | | PascalCase with spaces | Match job roles or functions |

---

## Naming Style Conventions

- **PascalCase**: First letter of each word capitalized → `AccountManager`
- **camelCase**: First word lowercase, rest capitalized → `accountManager`
- **lowercase**: All lowercase → `accountmanager`
- **snake_case**: Words separated by underscore → `account_manager`
- **kebab-case**: Words separated by hyphen → `account-manager`
- **PascalCase with spaces**: Like PascalCase but allowing spaces → `Account Manager`

**Author**: Francisco Antonio Fernández Coloma  
**Date**: February 2026  
**Version**: 1.0  
**License**: Internal use - All rights reserved
# Introduction 
This module aims to simplify automation routines by making them more resilient and less prone to manual misconfiguration.

# Components
The core idea of this module is better script execution by splitting individual tasks into a sequence simple well defined steps doing one thing at a time.
Each step consists of an ExecutionAction and a relative RecoverAction undoing the changes the ExecutionAction does in case a later step produces an error.
This concept allows for a sequential execution of multiple subsequent functions calls guaranteeing 
# Getting Started
Install the module from the PS Gallery

Install-Module -Name PS-AutomationHelper
# Build and Test
Run '/Tests/Invoke-Executions.Tests.ps1'. Pester version 5 is required
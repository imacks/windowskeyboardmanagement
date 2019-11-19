# #####################################################################
# Module manifest for module 'WindowsKeyboardManagement'
#
# iMacks
# Last update: 2019-11-19
#
# This is a generated file. Modifications will be lost on the next 
# generate sequence.
#
# #####################################################################

@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'WindowsKeyboardManagement.psm1'

    # Version number of this module.
    ModuleVersion = '2.1.1'

    # ID used to uniquely identify this module
    GUID = '190f3cee-85d5-48d0-9152-31f8ca5d335a'

    # Author of this module
    Author = 'iMacks'

    # Company or vendor of this module
    CompanyName = 'iMacks'

    # Copyright statement for this module
    Copyright = 'Copyright (c) 2019 iMacks. All rights reserved.'

    # Can run on these systems
    CompatiblePSEditions = @("Core")

    # Description of the functionality provided by this module
    Description = 'Allows keys on the physical keyboard to be remapped, and redefine programs associated with multimedia keys. For example, you can remap the "Scroll Lock" key to the "Calculator" multimedia key, and then redefine "Calculator" key to launch PowerShell. Now pressing "Scroll Lock" launches PowerShell!'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    #PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    #PowerShellHostVersion = '3.0'

    # Minimum version of Microsoft .NET Framework required by this module
    #DotNetFrameworkVersion = '4.5'

    # Minimum version of the common language runtime (CLR) required by this module
    #CLRVersion = '4.0'

    # Processor architecture (None, X86, Amd64) required by this module
    ProcessorArchitecture = 'None'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()

    # First load importing this module. Depreciated (use 'RootModule').
    # ModuleToProcess = ''
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = ''

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-WindowsKeyboardMap'
        'Set-WindowsKeyboardMap'
        'Clear-WindowsKeyboardMap'
        'Remove-WindowsKeyboardMap'
        'Get-WindowsMediaKey'
        'Set-WindowsMediaKey'
        'Remove-WindowsMediaKey'
        'Reset-WindowsMediaKey'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    # VariablesToExport = @()

    # Aliases to export from this module
    # AliasesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        # PSData is module packaging and gallery metadata embedded in PrivateData
        # It's for rebuilding NuGet-style packages
        # We had to do this because it's the only place we're allowed to extend the manifest
        # https://connect.microsoft.com/PowerShell/feedback/details/421837
        PSData = @{
            # The primary categorization of this module (from the TechNet Gallery tech tree).
            Category = 'Scripting Techniques'

            # Keyword tags to help users find this module via navigations and search.
            Tags = @('powershell', 'keyboard', 'windows', 'map', 'mapping', 'media', 'multimedia')

            # The web address of an icon which can be used in galleries to represent this module
            IconUri = 'https://raw.githubusercontent.com/imacks/windowskeyboardmanagement/master/icon.png'

            # The web address of this module's project or support homepage.
            ProjectUri = 'https://www.github.com/imacks/windowskeyboardmanagement'

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri = 'https://www.github.com/imacks/windowskeyboardmanagement/LICENSE'

            # Release notes for this particular version of the module
            ReleaseNotes = 'https://www.github.com/imacks/windowskeyboardmanagement/README.md'

            # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
            RequireLicenseAcceptance = 'False'

            # Indicates this is a pre-release/testing version of the module.
            IsPrerelease = 'False'
        }
    }

    # HelpInfo URI of this module
    HelpInfoURI = 'https://www.github.com/imacks/windowskeyboardmanagement/README.md'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

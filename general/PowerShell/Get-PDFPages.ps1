#Usage: This script must exist on C:\scripts 
#You must download XPDF from http://www.xpdfreader.com/download.html, and put the pdfinfo.exe on c:\scripts

param(
    [Parameter(HelpMessage="The folder to scan where the PDF files are located.")]
    $folderPathToScan,

    [Parameter(HelpMessage="The folder to scan where the PDF files are located.")]
    $output
)

function main() {
    $pdfFiles = Get-ChildItem -Path $folderPathToScan -Filter *.pdf -Recurse

    $totalPages = 0
    $totalFiles = 0

    $files = @()

    foreach($file in $pdfFiles){
        $pdfFileTotalPage = (c:\scripts\pdfinfo $file.FullName | Select-String -Pattern '(?<=Pages:\s*)\d+').Matches.Value

        $totalPages += $pdfFileTotalPage
        $totalFiles++

        $thisPDFFileObject = New-Object -TypeName PSObject
        $thisPDFFileObject | Add-Member -NotePropertyName PDFFile -NotePropertyValue $file.FullName
        $thisPDFFileObject | Add-Member -NotePropertyName Pages -NotePropertyValue $pdfFileTotalPage

        $files += $thisPDFFileObject
    }

    if ($output) {
        $files | Export-Csv -Path $output 
    }

    Write-Output "Total Number of pages $($totalPages) for all $($totalFiles) PDF Files."
    $files | FT -AutoSize
}

main
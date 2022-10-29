$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.GroupBox]$GroupBox1 = $null
[System.Windows.Forms.GroupBox]$GroupBox2 = $null
[System.Windows.Forms.GroupBox]$GroupBox3 = $null
[System.Windows.Forms.GroupBox]$GroupBox4 = $null
[System.Windows.Forms.GroupBox]$GroupBox5 = $null
[System.Windows.Forms.GroupBox]$GroupBox6 = $null
[System.Windows.Forms.GroupBox]$GroupBox7 = $null
[System.Windows.Forms.TextBox]$TextBoxHostname = $null
[System.Windows.Forms.TextBox]$TextBoxUserID   = $null
#[System.Windows.Forms.TextBox]$txtStatus       = $null
[System.Windows.Forms.RichTextBox]$txtStatus       = $null

[System.Windows.Forms.Button]$okButton     = $null
[System.Windows.Forms.Button]$cancelButton = $null
[System.Windows.Forms.Button]$reportButton     = $null

[System.Windows.Forms.CheckedListBox]$CheckedListBox = $null
[System.Windows.Forms.PictureBox]$pictureBox
[System.Windows.Forms.PictureBox]$pictureBox2
[System.Windows.Forms.Label]$label
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'Retrofit-form.resources.ps1')
$GroupBox1 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$GroupBox2 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$GroupBox3 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$GroupBox4 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$GroupBox5 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$GroupBox6 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$GroupBox7 = (New-Object -TypeName System.Windows.Forms.GroupBox)
$TextBoxHostname = (New-Object -TypeName System.Windows.Forms.TextBox)
$TextBoxUserID   = (New-Object -TypeName System.Windows.Forms.TextBox)
#$txtStatus       = (New-Object -TypeName System.Windows.Forms.TextBox)
$txtStatus       = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$pictureBox = (New-Object -TypeName System.Windows.Forms.PictureBox)
$pictureBox2 = (New-Object -TypeName System.Windows.Forms.PictureBox)
$okButton = (New-Object -TypeName System.Windows.Forms.Button)
$cancelButton = (New-Object -TypeName System.Windows.Forms.Button)
$reportButton = (New-Object -TypeName System.Windows.Forms.Button)
$label = (New-Object -TypeName System.Windows.Forms.Label)
$CheckedListBox = (New-Object -TypeName System.Windows.Forms.CheckedListBox)

$Form1.SuspendLayout()
$GroupBox1.SuspendLayout()
$GroupBox2.SuspendLayout()
$GroupBox3.SuspendLayout()
$GroupBox4.SuspendLayout()
$GroupBox5.SuspendLayout()
$GroupBox6.SuspendLayout()
$GroupBox7.SuspendLayout()
#
#TextBoxHostname
#
$TextBoxHostname.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]15))
$TextBoxHostname.Name = [System.String]'TextBoxHostname'
$TextBoxHostname.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]165,[System.Int32]21))
$TextBoxHostname.TabIndex = [System.Int32]0
#
#TextBoxUserID
#
$TextBoxUserID.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]15))
$TextBoxUserID.Name = [System.String]'TextBoxUserID'
$TextBoxUserID.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]165,[System.Int32]21))
$TextBoxUserID.TabIndex = [System.Int32]1
#
#GroupBox1
#
$GroupBox1.Controls.Add($TextBoxHostname)
$GroupBox1.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$GroupBox1.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$GroupBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]14))
$GroupBox1.Name = [System.String]'GroupBox1'
$GroupBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]177,[System.Int32]45))
$GroupBox1.TabIndex = [System.Int32]0
$GroupBox1.TabStop = $false
$GroupBox1.Text = [System.String]'Hostname'
$GroupBox1.UseCompatibleTextRendering = $true
#
#GroupBox2
#
$GroupBox2.Controls.Add($TextBoxUserID)
$GroupBox2.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$GroupBox2.ForeColor = [System.Drawing.SystemColors]::Highlighttext
#$GroupBox2.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$GroupBox2.ImeMode = [System.Windows.Forms.ImeMode]::NoControl
$GroupBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]189,[System.Int32]14))
$GroupBox2.Name = [System.String]'GroupBox2'
$GroupBox2.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$GroupBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]177,[System.Int32]45))
$GroupBox2.TabIndex = [System.Int32]1
$GroupBox2.TabStop = $false
$GroupBox2.Text = [System.String]'UserID'
$GroupBox2.UseCompatibleTextRendering = $true
#
#GroupBox3
#
$GroupBox3.Controls.Add($GroupBox6)
$GroupBox3.Controls.Add($GroupBox2)
$GroupBox3.Controls.Add($GroupBox1)
$GroupBox3.Controls.Add($GroupBox4)
$GroupBox3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]100))
$GroupBox3.Name = [System.String]'GroupBox3'
$GroupBox3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]551,[System.Int32]178))
$GroupBox3.TabIndex = [System.Int32]2
$GroupBox3.TabStop = $false
$GroupBox3.UseCompatibleTextRendering = $true
#
#GroupBox6
#
$GroupBox6.Controls.Add($okButton)
$GroupBox6.Controls.Add($cancelButton)
$GroupBox6.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]372,[System.Int32]14))
$GroupBox6.Name = [System.String]'GroupBox6'
$GroupBox6.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]173,[System.Int32]45))
$GroupBox6.TabIndex = [System.Int32]5
$GroupBox6.TabStop = $false
$GroupBox6.UseCompatibleTextRendering = $true
#
#okButton
#
$okButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]13))
$okButton.Name = [System.String]'okButton'
$okButton.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$okButton.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$okButton.BackColor = '#00A3E1'
$okButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]81,[System.Int32]23))
$okButton.TabIndex = [System.Int32]3
$okButton.Text = [System.String]'Start'
$okButton.UseCompatibleTextRendering = $true
$okButton.UseVisualStyleBackColor = $true
$okButton.add_Click($okButton_Click)
#
#cancelButton
#
$cancelButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]93,[System.Int32]13))
$cancelButton.Name = [System.String]'cancelButton'
$cancelButton.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$cancelButton.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$cancelButton.BackColor = '#00A3E1'
$cancelButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]74,[System.Int32]23))
$cancelButton.TabIndex = [System.Int32]4
$cancelButton.Text = [System.String]'Cancel'
$cancelButton.UseCompatibleTextRendering = $true
$cancelButton.UseVisualStyleBackColor = $true
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
#
#reportlButton
#
$reportButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]15,[System.Int32]21))
$reportButton.Name = [System.String]'reportButton'
$reportButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]94,[System.Int32]23))
$reportButton.TabIndex = [System.Int32]5
$reportButton.Text = [System.String]'OU Computers'
$reportButton.UseCompatibleTextRendering = $true
$reportButton.UseVisualStyleBackColor = $true
$reportButton.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$reportButton.BackColor = '#00A3E1'
$reportButton.add_Click($reportButton_Click)
#
#GroupBox4
#
$GroupBox4.Controls.Add($CheckedListBox)
$GroupBox4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]65))
$GroupBox4.Name = [System.String]'GroupBox4'
$GroupBox4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]539,[System.Int32]103))
$GroupBox4.TabIndex = [System.Int32]6
$GroupBox4.TabStop = $false
$GroupBox4.Text = [System.String]'Process'
$GroupBox4.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$GroupBox4.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$GroupBox4.UseCompatibleTextRendering = $true
#
#CheckedListBox
#
$CheckedListBox.CheckOnClick = $true
$CheckedListBox.FormattingEnabled = $true
$CheckedListBox.Items.AddRange([System.Object[]]@('Move computer OU Windows_10',[System.String]'Add host group "despliegue_sccm"',[System.String]'Add user group GU-KOF-INTUNE',[System.String]'Add host collecttion SCCM_INTUNE',[System.String]'Add user group Eliminar PIN',[System.String]'Delete host from AD',[System.String]'Delete host from SCCM',[System.String]'Move computer OU Windows_10_Apps'))
$CheckedListBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]18))
$CheckedListBox.Name = [System.String]'CheckedListBox'
$CheckedListBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]527,[System.Int32]85))
$CheckedListBox.TabIndex = [System.Int32]2
$CheckedListBox.UseCompatibleTextRendering = $true
$CheckedListBox.add_SelectedIndexChanged($CheckedListBox_SelectedIndexChanged)
$CheckedListBox.MultiColumn = $true
$CheckedListBox.ColumnWidth = 250
$CheckedListBox.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$CheckedListBox.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$CheckedListBox.BackColor = '#63666A'
#GroupBox5
#
$GroupBox5.Controls.Add($txtStatus)
$GroupBox5.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]284))
$GroupBox5.Name = [System.String]'GroupBox5'
$GroupBox5.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]551,[System.Int32]234))
$GroupBox5.TabIndex = [System.Int32]7
$GroupBox5.TabStop = $false
$GroupBox5.Text = [System.String]'Result'
$GroupBox5.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$GroupBox5.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$GroupBox5.UseCompatibleTextRendering = $true
#
#txtStatus
#
$txtStatus.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]20))
$txtStatus.Name = [System.String]'txtStatus'
$txtStatus.ReadOnly = $true
$txtStatus.multiline = $true
$txtStatus.Scrollbars = "Vertical"
$txtStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]527,[System.Int32]206))
$txtStatus.TabIndex = [System.Int32]6
$txtStatus.Text = [System.String]'Waiting...'
$txtStatus.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]8))
#
#Picturebox
#
$file = (get-item 'DXC_Logo.png')
$img = [System.Drawing.Image]::Fromfile($file)
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Image = $img
$pictureBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]15,[System.Int32]12))
$pictureBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]107,[System.Int32]21))
#
#Picturebox2
#
$file2 = (get-item 'FEMSA_Logo.png')
$img2 = [System.Drawing.Image]::Fromfile($file2)
$pictureBox2 = new-object Windows.Forms.PictureBox
$pictureBox2.Image = $img2
$pictureBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]515,[System.Int32]12))
$pictureBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]45,[System.Int32]26))
$Form1.Controls.Add($pictureBox2)
#

#
#Label1
#
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(176,12)
$label.Size = New-Object System.Drawing.Size(337,32)
$label.Text = 'Automated AD Script Tool'
$label.Font = 'Arial,13,style=Bold'
$label.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$Form1.Controls.Add($label)
#
#GroupBox7
#
$GroupBox7.Controls.Add($reportButton)
$GroupBox7.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]40))
$GroupBox7.Name = [System.String]'GroupBox7'
$GroupBox7.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]550,[System.Int32]58))
$GroupBox7.TabIndex = [System.Int32]0
$GroupBox7.TabStop = $false
$GroupBox7.UseCompatibleTextRendering = $true
$GroupBox7.Text = [System.String]'Report'
$GroupBox7.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Arial',[System.Single]9))
$GroupBox7.ForeColor = [System.Drawing.SystemColors]::Highlighttext
$Form1.Controls.Add($GroupBox7)
#$Form1.Controls.Add($reportButton)
#
#Form1
#
$Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]574,[System.Int32]526))
$Form1.Controls.Add($GroupBox5)
$Form1.Controls.Add($GroupBox3)
$Form1.Controls.Add($pictureBox)
$Form1.BackColor = '#63666A'#[System.Drawing.SystemColors]::ControlDark
$Form1.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$Form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form1.Text = [System.String]'Script Retrofit'
$GroupBox1.ResumeLayout($false)
$GroupBox1.PerformLayout()
$GroupBox2.ResumeLayout($false)
$GroupBox2.PerformLayout()
$GroupBox3.ResumeLayout($false)
$GroupBox6.ResumeLayout($false)
$GroupBox4.ResumeLayout($false)
$GroupBox5.ResumeLayout($false)
$GroupBox7.ResumeLayout($false)
$Form1.ResumeLayout($false)
Add-Member -InputObject $Form1 -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox1 -Value $GroupBox1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name TextBoxUserID -Value $TextBoxUserID -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name TextBoxHostname -Value $TextBoxHostname -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox2 -Value $GroupBox2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox3 -Value $GroupBox3 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox6 -Value $GroupBox6 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name okButton -Value $okButton -MemberType NoteProperty
#Add-Member -InputObject $Form1 -Name reportButton -Value $reportButton -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox4 -Value $GroupBox4 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name CheckedListBox -Value $CheckedListBox -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name GroupBox5 -Value $GroupBox5 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name txtStatus -Value $txtStatus -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name pictureBox -Value $pictureBox -MemberType NoteProperty
#Add-Member -InputObject $Form1 -Name pictureBox2 -Value $pictureBox2 -MemberType NoteProperty
#Add-Member -InputObject $Form1 -Name label -Value $label -MemberType NoteProperty
}
. InitializeComponent

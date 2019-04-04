# COmDIrect-POstfach-DOwnloader: codipodo
# Dieses Programm holt die PDF-Dokumente der ersten Seite der Postbox
# und legt sie im Ausgabeverzeichenis (s.u.) ab

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'mechanize'

# LOGINDATEN, bitte anpassen
ID = "1234578"  # Comdirect-Zugangsnummer
PIN = "123456"  # Comdirect-PIN

# Ablageort der heruntergeladenen Dateien
DIRECTORY="comdirect-postbox"

# Feste URLs der Comdirect
LOGINURL="https://kunde.comdirect.de/lp/wt/login"
LOGOUTURL="https://kunde.comdirect.de/lp/wt/logout"
POSTBOX_URL="https://kunde.comdirect.de/itx/posteingangsuche"
SUCCESSPAGE="https://kunde.comdirect.de/itx/persoenlicherbereich/anzeigen?execution=e1s1"

  @agent = Mechanize.new
  
  @agent.get(LOGINURL) do |page|
     login_result = page.form_with(:name => 'login') do |log|
       log.add_field!("loginAction", "loginAction")
       log.param1= ID
       log.param3 = PIN
     end.click_button

     # Sind wir auf der richtigen Seite gelandet?"
     if login_result.uri.to_s != SUCCESSPAGE
       puts "Login fehlgeschlagen,  aktuelle URL: #{login_result.uri.to_s}"
       break
     end

    @agent.get(POSTBOX_URL)

    # Nur Eintraege, deren URL "/dokumentenabruf/" enthält, abholen,
    # d.h. Werbung oder andere nicht-downloadbare Elemente überspringen
    @agent.page.links_with(:href => /dokumentenabruf/).each do |link|
      filename = link.href.split('/')[-1]
    
      if idx = filename.rindex(".pdf")
        filename = filename[0..(idx+3)]
      end

      path = File.join DIRECTORY, filename
      result = link.click.save! path
    end
  end
  @agent.get(LOGOUTURL)

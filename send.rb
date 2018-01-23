#Robert May
#Jan 2018
#Spams texts

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

def read(file)
  lines = []
  File.open(file).each do |line|
    lines.push(line)
  end
  return lines[0]
end

def save(file, text)
  File.open(file, 'w') {|fil| fil.write(text.to_s)}
end

def getArgs(arglist)
  action = "givingMess"
  types = {"-sm" => "savingMess", "-sw" => "savingWrap", "-m" => "givingMess", "-w" => "givingWrap", "-lm" => "loadingMess", "-lw" => "loadingWrap", "-dm" => "deletingMess", "-dw" => "deletingWrap"}
  typeList = ["-sm", "-sw", "-m", "-w", "-lm", "-lw", "-dm", "-dw"]
  sectionInd = 0
  messList = []
  wrapList = []
  messDict = {}
  wrapDict = {}
  key = ""
  arglist.each do |arg|
    if typeList.include?(arg)
      sectionInd = 0
      action = types[arg]
    end
    if action == "savingMess"
      if sectionInd == 1
        messDict = read("./messages.txt")
        if messDict
          messDict = eval(messDict)
        else
          messDict = {}
        end
        key = arg
        messDict[arg] ||= []
      elsif sectionInd > 1
        messDict[key].push(arg)
        save("./messages.txt", messDict)
      end
    elsif action == "savingWrap"
      if sectionInd == 1
        wrapDict = read("./wrappers.txt")
        if wrapDict
          wrapDict = eval(wrapDict)
        else
          wrapDict = {}
        end
        key = arg
        wrapDict[arg] ||= []
      elsif sectionInd > 1
        wrapDict[key].push(arg)
        save("./wrappers.txt", wrapDict)
      end
    elsif action == "loadingMess"
      if sectionInd >= 1
        messList ||= []
        messDict = eval(read("./messages.txt"))
        messList.concat(messDict[arg])
      end
    elsif action == "loadingWrap"
      if sectionInd >= 1
        wrapList ||= []
        wrapDict = eval(read("./wrappers.txt"))
        wrapList += wrapDict[arg]
      end
    elsif action == "deletingMess"
      if sectionInd >= 1
        messDict = eval(read("./messages.txt"))
        messDict.delete(arg)
        save("./messages.txt", messDict)
      end
    elsif action == "deletingWrap"
      if sectionInd >= 1
        wrapDict = eval(read("./wrappers.txt"))
        wrapDict.delete(arg)
        save("./wrappers.txt", wrapDict)
      end
    elsif action == "givingMess"
      if sectionInd >= 1
        messList.push(arg)
      end
    elsif action == "givingWrap"
      if sectionInd >= 1
        wrapList.push(arg)
      end
    end
    sectionInd += 1
  end
  return messList, wrapList
end

def getMess(messList, wrapList)
  fullList = messList + wrapList
  while messList == [] || fullList == []
    print("Please input messages separated by ';' (at least 1): ")
    messList += STDIN.gets.chomp.split(';')
    print("Please input wrappers separated by ';' (optional): ")
    wrapList += STDIN.gets.chomp.split(';')
    fullList += messList + wrapList
  end
  message = fullList[Random.rand(0...fullList.length)]
  messChar = 0
  addNext = true
  retmess = ""
  message.split("").each do |char|
    if addNext
      if char == "@" && message.split("")[messChar + 1] == "@"
        addNext = false
        retmess += messList[Random.rand(0...messList.length)]
      else
        retmess += char
      end
    else
      addNext = true
    end
    messChar += 1
  end
  return retmess, messList, wrapList
end

def send(person, timeInt, args, messList=[], wrapList=[])
  system("osascript \"./getcontacts.txt\"")
  contacts = read("contacts.txt").split(";")
  contacts.push("[nobody]")
  while contacts.include?(person) == false
    print "Please input a valid contact name: "
    person = STDIN.gets.chomp
  end
  if timeInt.to_s.numeric? == false
    timeInt = nil
  end
  timeInt ||=0.5
  if args.length > 2
    messwrap = getArgs(args[2...args.length])
  end
  if messwrap == nil
    message, messList, wrapList = getMess(messList, wrapList)
  else
    message, messList, wrapList = getMess(messwrap[0], messwrap[1])
  end
  while true && person != "[nobody]"
    message, messList, wrapList = getMess(messList, wrapList)
    system("osascript -e 'tell application \"Messages\" to send \"#{message}\" to buddy \"#{person}\"'")
    sleep timeInt.to_f
    args = []
  end
end

send(ARGV[0], ARGV[1], ARGV)

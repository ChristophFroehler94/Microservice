using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FotoFinder.PolFlashXe.FlashViscaComHandler
{
    public class ViscaDataBuffer
    {
        // read and write pointer
        public int WritePointer { get; private set; }

        // status statements
        public int FreeSpaceLeft { get { return Size - WritePointer; } }
        public int BytesToRead { get { return WritePointer - 1; } }
        public bool IsFull { get { return WritePointer == Size; } }
        public bool IsEmpty { get { return WritePointer == 0; } }

        // buffersize
        public int Size { get; private set; }

        // the actual array
        public byte[] Content { get; private set; }

        // Constructors
        public ViscaDataBuffer(int size)
        {
            Size = size;
            Content = new byte[size];
        }

        public ViscaDataBuffer(byte[] buffer)
        {
            Content = buffer;
            Size = buffer.Length;
        }

        public byte[] GetContent()
        {
            byte[] output = new byte[WritePointer];
            Array.Copy(Content, output, WritePointer);
            return output;
        }

        public bool Push(byte newByte)
        {
            if (WritePointer < Size)
            {
                Content[WritePointer] = newByte;
                WritePointer++;
                return true;
            }
            return false;
        }

        public void Reset()
        {
            WritePointer = 0;
        }
    }
}
